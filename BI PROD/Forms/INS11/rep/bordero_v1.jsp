<%@ taglib uri="/WEB-INF/lib/reports_tld.jar" prefix="rw" %>
<%@ page language="java" import="java.io.*" errorPage="/rwerror.jsp" session="false" %>
<%@ page contentType="application/vnd.ms-excel;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<rw:report id="report"> 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="bordero" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="BORDERO" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="CLAIM_H_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_BORD_PACK_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="FUND_BRIEF" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_BORDERO">
      <select>
      <![CDATA[select bp.RE_BORDERO_PACKAGE_ID, 
ent.obj_name('CONTACT', mc.assignor_id) cendant,
bp.START_DATE, bp.END_DATE, f.BRIEF, f.CODE, f.NAME from 
ven_re_bordero_package bp, ven_fund f,ven_re_main_contract mc, ven_re_contract_version cv
where cv.re_contract_version_id = bp.re_contract_id
and mc.re_main_contract_id = cv.re_main_contract_id
and bp.RE_BORDERO_PACKAGE_ID = :P_BORD_PACK_ID
and f.BRIEF = :fund_brief]]>
      </select>
      <displayInfo x="0.22913" y="0.08350" width="1.27087" height="0.26038"/>
      <group name="G_BORDERO">
        <displayInfo x="0.05615" y="0.73120" width="1.92297" height="1.62695"
        />
        <dataItem name="cendant" datatype="vchar2" columnOrder="20"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Cendant">
          <dataDescriptor
           expression="ent.obj_name ( &apos;CONTACT&apos; , mc.assignor_id )"
           descriptiveExpression="CENDANT" order="2" width="4000"/>
        </dataItem>
        <dataItem name="RE_BORDERO_PACKAGE_ID" oracleDatatype="number"
         columnOrder="14" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Re Bordero Package Id">
          <dataDescriptor expression="bp.RE_BORDERO_PACKAGE_ID"
           descriptiveExpression="RE_BORDERO_PACKAGE_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="START_DATE" datatype="date" oracleDatatype="date"
         columnOrder="15" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Start Date">
          <dataDescriptor expression="bp.START_DATE"
           descriptiveExpression="START_DATE" order="3" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="END_DATE" datatype="date" oracleDatatype="date"
         columnOrder="16" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="End Date">
          <dataDescriptor expression="bp.END_DATE"
           descriptiveExpression="END_DATE" order="4" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="BRIEF" datatype="vchar2" columnOrder="17" width="30"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Brief">
          <dataDescriptor expression="f.BRIEF" descriptiveExpression="BRIEF"
           order="5" width="30"/>
        </dataItem>
        <dataItem name="CODE" datatype="vchar2" columnOrder="18" width="3"
         defaultWidth="30000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Code">
          <dataDescriptor expression="f.CODE" descriptiveExpression="CODE"
           order="6" width="3"/>
        </dataItem>
        <dataItem name="NAME" datatype="vchar2" columnOrder="19" width="150"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Name">
          <dataDescriptor expression="f.NAME" descriptiveExpression="NAME"
           order="7" width="150"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_BORDERO_TYPE">
      <select canParse="no">
      <![CDATA[select rb.RE_BORDERO_PACKAGE_ID, rb.RE_BORDERO_ID, rbt.BRIEF, rbt.NAME, 
pkg_rep_utils.to_money_sep((select sum(rcc.re_premium) 
from 
VEN_REL_RECOVER_BORDERO RRB,
ven_re_calculation rcc,
entity e
where e.brief = 'REL_RECOVER_BORDERO'
and rcc.uro_id = rrb.rel_recover_BORDERO_ID
and rcc.ure_id = e.ent_id and rrb.RE_BORDERO_ID = rb.RE_BORDERO_ID)) sum_re_premium--перестраховочная премия за период
from 
VEN_RE_BORDERO rb, VEN_RE_BORDERO_TYPE rbt, ven_fund f
where rb.re_bordero_type_id=rbt.re_bordero_type_id
and rb.RE_BORDERO_PACKAGE_ID = :P_BORD_PACK_ID
and f.fund_id=rb.fund_id
and f.BRIEF = :fund_brief
]]>
      </select>
      <displayInfo x="2.38599" y="0.07300" width="2.06213" height="0.32983"/>
      <group name="G_BORDERO_TYPE">
        <displayInfo x="2.32678" y="1.15845" width="2.17126" height="1.11426"
        />
        <dataItem name="SUM_RE_PREMIUM" datatype="vchar2" columnOrder="64"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Sum Re Premium">
          <dataDescriptor expression="SUM_RE_PREMIUM"
           descriptiveExpression="SUM_RE_PREMIUM" order="5" width="4000"/>
        </dataItem>
        <dataItem name="BRIEF1" datatype="vchar2" columnOrder="23" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Brief1">
          <dataDescriptor expression="BRIEF" descriptiveExpression="BRIEF"
           order="3" width="50"/>
        </dataItem>
        <dataItem name="NAME1" datatype="vchar2" columnOrder="24" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Name1">
          <dataDescriptor expression="NAME" descriptiveExpression="NAME"
           order="4" width="255"/>
        </dataItem>
        <dataItem name="RE_BORDERO_PACKAGE_ID1" oracleDatatype="number"
         columnOrder="21" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Re Bordero Package Id1">
          <dataDescriptor expression="RE_BORDERO_PACKAGE_ID"
           descriptiveExpression="RE_BORDERO_PACKAGE_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="RE_BORDERO_ID" oracleDatatype="number"
         columnOrder="22" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Re Bordero Id">
          <dataDescriptor expression="RE_BORDERO_ID"
           descriptiveExpression="RE_BORDERO_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_BORDERO_LINE">
      <select>
      <![CDATA[select rrb.RE_BORDERO_ID, trim(pp.pol_ser || ' ' || pp.pol_num) num_pol,
plo.DESCRIPTION progr,
pr.BRIEF, pr.DESCRIPTION,
vc.NAME famil,
vc.FIRST_NAME,
vc.MIDDLE_NAME,
aa.NAME fio,
cnp.DATE_OF_BIRTH,
decode(cnp.GENDER,0,'F','M') pol,
decode(cnp.GENDER,0,'Жен.','Муж.') pol_d,
aa.NOTE,
pkg_rep_utils.to_money_sep(round(rc.ins_amount,0)) ins_amount,
ltrim(to_char(round(rcc.re_tariff,6), '999G999G999G999G999G999G990D999999', 'NLS_NUMERIC_CHARACTERS = '', ''')) re_tariff,
pkg_rep_utils.to_money_sep(round(rcc.base_rate_reins,2)) base_rate_reins,
pkg_rep_utils.to_money_sep(round(rc.PART_SUM,2)) PART_SUM,
pkg_rep_utils.to_money_sep(rc.BRUTTO_PREMIUM) br_prem28,
pkg_rep_utils.to_money_sep(rrb.BRUTTO_PREMIUM) br_prem36,
trunc(pc.START_DATE) s_date_strax,
trunc(pc.END_DATE) e_date_strax,
trunc(pp.START_DATE) s_date_waiting,
trunc(pp.waiting_period_end_date)-trunc(pp.START_DATE)+1 days_waiting,  
trunc(pp.waiting_period_end_date) waiting_period_end_date,
vtp.DESCRIPTION per_opl,
acp.plan_DATE opl_s,
add_months(acp.plan_date,12/vtp.NUMBER_OF_PAYMENTS)-1 opl_e,
nvl(Pkg_Policy.is_in_waiting_period(pp.policy_id, pp.waiting_period_id, pp.start_date),0) is_in_waiting_period,
round(CEIL (MONTHS_BETWEEN (NVL (trunc(pp.END_DATE), SYSDATE), NVL (pp.START_DATE, SYSDATE)) / 12) + 
     ((MONTHS_BETWEEN (NVL (pp.END_DATE, SYSDATE), NVL (pp.START_DATE, SYSDATE)) - 
        (12 * CEIL (MONTHS_BETWEEN (NVL (pp.END_DATE, SYSDATE), NVL (pp.START_DATE, SYSDATE)) / 12))) / 100),2) dog_dest,
pkg_rep_utils.to_money_sep(round(rcc.FIRST_INS_GUARANTEE,2)) FIRST_INS_GUARANTEE, --первоначальное страховое обеспечение под риском
round(nvl(rcc.part_sum*100,0),2) part_perc, --доля перестраховщика в %
pkg_rep_utils.to_money_sep(round(rcc.reins_guarantee,2)) reins_guarantee,--первоначальное перестрахованное обеспечение под риском
pkg_rep_utils.to_money_sep(round(rcc.ins_guarantee,2)) ins_guarantee,--страховое обеспечение под риском
nvl(rcc.k_coef_m,0) k_coef_m,--медицинский коэффициент в %
nvl(rcc.s_coef_m,0) s_coef_m,--медицинский коэффициент в %%
nvl(rcc.k_coef_nm,0) k_coef_nm,--немедицинский коэффициент в %
nvl(rcc.s_coef_nm,0) s_coef_nm,--немедицинский коэффициент в %%
ltrim(to_char(round(rcc.k_down_payment,6), '999G999G999G999G999G999G990D999999', 'NLS_NUMERIC_CHARACTERS = '', ''')) k_down_payment,--коэффициент рассрочки
pkg_rep_utils.to_money_sep(round(rcc.re_premium,2)) re_premium--перестраховочная премия за период
from 
VEN_REL_RECOVER_BORDERO RRB,
RE_COVER RC,
VEN_P_COVER PC, 
VEN_AS_ASSET aa, 
VEN_P_POLICY pp,
VEN_P_POL_HEADER ph,
VEN_T_PRODUCT pr,
VEN_CONTACT vc,
VEN_CN_PERSON cnp,
VEN_T_PAYMENT_TERMS vtp,
ven_t_prod_line_option plo,
ven_ac_payment acp,
ven_re_calculation rcc,
entity e,
ven_as_assured ass
where RRB.RE_COVER_ID = RC.RE_COVER_ID
AND RC.P_COVER_ID = PC.P_COVER_ID
AND PC.AS_ASSET_ID = aa.AS_ASSET_ID
AND aa.P_POLICY_ID = pp.POLICY_ID
AND pp.POL_HEADER_ID = ph.POLICY_HEADER_ID
AND ph.PRODUCT_ID = pr.PRODUCT_ID
and ass.as_assured_id = aa.as_asset_id
AND ass.assured_contact_id = vc.CONTACT_ID
AND vc.CONTACT_ID = cnp.CONTACT_ID
AND pc.t_prod_line_option_id = plo.ID
AND pp.payment_term_id = vtp.Id
AND rrb.AC_PAYMENT_ID = acp.PAYMENT_ID(+)
and e.brief = 'REL_RECOVER_BORDERO'
and rcc.uro_id = rrb.rel_recover_BORDERO_ID
and rcc.ure_id = e.ent_id
]]>
      </select>
      <displayInfo x="4.89575" y="0.07288" width="1.83325" height="0.32983"/>
      <group name="G_BORDERO_LINE">
        <displayInfo x="4.84790" y="0.64587" width="1.92126" height="6.92480"
        />
        <dataItem name="FIRST_INS_GUARANTEE" datatype="vchar2"
         columnOrder="54" width="4000" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="First Ins Guarantee">
          <dataDescriptor
           expression="pkg_rep_utils.to_money_sep ( round ( rcc.FIRST_INS_GUARANTEE , 2 ) )"
           descriptiveExpression="FIRST_INS_GUARANTEE" order="30" width="4000"
          />
        </dataItem>
        <dataItem name="part_perc" oracleDatatype="number" columnOrder="55"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Part Perc">
          <dataDescriptor
           expression="round ( nvl ( rcc.part_sum * 100 , 0 ) , 2 )"
           descriptiveExpression="PART_PERC" order="31"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="reins_guarantee" datatype="vchar2" columnOrder="56"
         width="4000" defaultWidth="20000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Reins Guarantee">
          <dataDescriptor
           expression="pkg_rep_utils.to_money_sep ( round ( rcc.reins_guarantee , 2 ) )"
           descriptiveExpression="REINS_GUARANTEE" order="32" width="4000"/>
        </dataItem>
        <dataItem name="ins_guarantee" datatype="vchar2" columnOrder="57"
         width="4000" defaultWidth="20000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ins Guarantee">
          <dataDescriptor
           expression="pkg_rep_utils.to_money_sep ( round ( rcc.ins_guarantee , 2 ) )"
           descriptiveExpression="INS_GUARANTEE" order="33" width="4000"/>
        </dataItem>
        <dataItem name="k_coef_m" oracleDatatype="number" columnOrder="58"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="K Coef M">
          <dataDescriptor expression="nvl ( rcc.k_coef_m , 0 )"
           descriptiveExpression="K_COEF_M" order="34" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="s_coef_m" oracleDatatype="number" columnOrder="59"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="S Coef M">
          <dataDescriptor expression="nvl ( rcc.s_coef_m , 0 )"
           descriptiveExpression="S_COEF_M" order="35" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="k_coef_nm" oracleDatatype="number" columnOrder="60"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="K Coef Nm">
          <dataDescriptor expression="nvl ( rcc.k_coef_nm , 0 )"
           descriptiveExpression="K_COEF_NM" order="36"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="s_coef_nm" oracleDatatype="number" columnOrder="61"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="S Coef Nm">
          <dataDescriptor expression="nvl ( rcc.s_coef_nm , 0 )"
           descriptiveExpression="S_COEF_NM" order="37"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="k_down_payment" datatype="vchar2" columnOrder="62"
         width="35" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="K Down Payment">
          <dataDescriptor
           expression="ltrim ( to_char ( round ( rcc.k_down_payment , 6 ) , &apos;999G999G999G999G999G999G990D999999&apos; , &apos;NLS_NUMERIC_CHARACTERS = &apos;&apos;, &apos;&apos;&apos; ) )"
           descriptiveExpression="K_DOWN_PAYMENT" order="38" width="35"/>
        </dataItem>
        <dataItem name="re_premium" datatype="vchar2" columnOrder="63"
         width="4000" defaultWidth="20000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Re Premium">
          <dataDescriptor
           expression="pkg_rep_utils.to_money_sep ( round ( rcc.re_premium , 2 ) )"
           descriptiveExpression="RE_PREMIUM" order="39" width="4000"/>
        </dataItem>
        <dataItem name="ins_amount" datatype="vchar2" columnOrder="51"
         width="4000" defaultWidth="20000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ins Amount">
          <dataDescriptor
           expression="pkg_rep_utils.to_money_sep ( round ( rc.ins_amount , 0 ) )"
           descriptiveExpression="INS_AMOUNT" order="14" width="4000"/>
        </dataItem>
        <dataItem name="re_tariff" datatype="vchar2" columnOrder="52"
         width="35" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Re Tariff">
          <dataDescriptor
           expression="ltrim ( to_char ( round ( rcc.re_tariff , 6 ) , &apos;999G999G999G999G999G999G990D999999&apos; , &apos;NLS_NUMERIC_CHARACTERS = &apos;&apos;, &apos;&apos;&apos; ) )"
           descriptiveExpression="RE_TARIFF" order="15" width="35"/>
        </dataItem>
        <dataItem name="base_rate_reins" datatype="vchar2" columnOrder="53"
         width="4000" defaultWidth="20000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Base Rate Reins">
          <dataDescriptor
           expression="pkg_rep_utils.to_money_sep ( round ( rcc.base_rate_reins , 2 ) )"
           descriptiveExpression="BASE_RATE_REINS" order="16" width="4000"/>
        </dataItem>
        <dataItem name="opl_s" datatype="date" oracleDatatype="date"
         columnOrder="49" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Opl S">
          <dataDescriptor expression="acp.plan_DATE"
           descriptiveExpression="OPL_S" order="26" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="opl_e" datatype="date" oracleDatatype="date"
         columnOrder="50" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Opl E">
          <dataDescriptor
           expression="add_months ( acp.plan_date , 12 / vtp.NUMBER_OF_PAYMENTS ) - 1"
           descriptiveExpression="OPL_E" order="27" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="br_prem28" datatype="vchar2" columnOrder="47"
         width="4000" defaultWidth="20000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Br Prem28">
          <dataDescriptor
           expression="pkg_rep_utils.to_money_sep ( rc.BRUTTO_PREMIUM )"
           descriptiveExpression="BR_PREM28" order="18" width="4000"/>
        </dataItem>
        <dataItem name="br_prem36" datatype="vchar2" columnOrder="48"
         width="4000" defaultWidth="20000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Br Prem36">
          <dataDescriptor
           expression="pkg_rep_utils.to_money_sep ( rrb.BRUTTO_PREMIUM )"
           descriptiveExpression="BR_PREM36" order="19" width="4000"/>
        </dataItem>
        <dataItem name="per_opl" datatype="vchar2" columnOrder="46"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Per Opl">
          <dataDescriptor expression="vtp.DESCRIPTION"
           descriptiveExpression="PER_OPL" order="25" width="500"/>
        </dataItem>
        <dataItem name="progr" datatype="vchar2" columnOrder="45" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Progr">
          <dataDescriptor expression="plo.DESCRIPTION"
           descriptiveExpression="PROGR" order="3" width="255"/>
        </dataItem>
        <dataItem name="RE_BORDERO_ID1" oracleDatatype="number"
         columnOrder="25" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Re Bordero Id1">
          <dataDescriptor expression="rrb.RE_BORDERO_ID"
           descriptiveExpression="RE_BORDERO_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="num_pol" datatype="vchar2" columnOrder="26"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Num Pol">
          <dataDescriptor
           expression="trim ( pp.pol_ser || &apos; &apos; || pp.pol_num )"
           descriptiveExpression="NUM_POL" order="2" width="2049"/>
        </dataItem>
        <dataItem name="BRIEF2" datatype="vchar2" columnOrder="27" width="30"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Brief2">
          <dataDescriptor expression="pr.BRIEF" descriptiveExpression="BRIEF"
           order="4" width="30"/>
        </dataItem>
        <dataItem name="DESCRIPTION" datatype="vchar2" columnOrder="28"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Description">
          <dataDescriptor expression="pr.DESCRIPTION"
           descriptiveExpression="DESCRIPTION" order="5" width="255"/>
        </dataItem>
        <dataItem name="famil" datatype="vchar2" columnOrder="29" width="500"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Famil">
          <dataDescriptor expression="vc.NAME" descriptiveExpression="FAMIL"
           order="6" width="500"/>
        </dataItem>
        <dataItem name="FIRST_NAME" datatype="vchar2" columnOrder="30"
         width="50" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="First Name">
          <dataDescriptor expression="vc.FIRST_NAME"
           descriptiveExpression="FIRST_NAME" order="7" width="50"/>
        </dataItem>
        <dataItem name="MIDDLE_NAME" datatype="vchar2" columnOrder="31"
         width="50" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Middle Name">
          <dataDescriptor expression="vc.MIDDLE_NAME"
           descriptiveExpression="MIDDLE_NAME" order="8" width="50"/>
        </dataItem>
        <dataItem name="fio" datatype="vchar2" columnOrder="32" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fio">
          <dataDescriptor expression="aa.NAME" descriptiveExpression="FIO"
           order="9" width="255"/>
        </dataItem>
        <dataItem name="DATE_OF_BIRTH" datatype="date" oracleDatatype="date"
         columnOrder="33" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Of Birth">
          <dataDescriptor expression="cnp.DATE_OF_BIRTH"
           descriptiveExpression="DATE_OF_BIRTH" order="10"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="pol" datatype="vchar2" columnOrder="34" width="1"
         defaultWidth="10000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pol">
          <dataDescriptor
           expression="decode ( cnp.GENDER , 0 , &apos;F&apos; , &apos;M&apos; )"
           descriptiveExpression="POL" order="11" width="1"/>
        </dataItem>
        <dataItem name="pol_d" datatype="vchar2" columnOrder="35" width="4"
         defaultWidth="40000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pol D">
          <dataDescriptor
           expression="decode ( cnp.GENDER , 0 , &apos;Жен.&apos; , &apos;Муж.&apos; )"
           descriptiveExpression="POL_D" order="12" width="4"/>
        </dataItem>
        <dataItem name="NOTE" datatype="vchar2" columnOrder="36" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Note">
          <dataDescriptor expression="aa.NOTE" descriptiveExpression="NOTE"
           order="13" width="4000"/>
        </dataItem>
        <dataItem name="PART_SUM" datatype="vchar2" columnOrder="37"
         width="4000" defaultWidth="20000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Part Sum">
          <dataDescriptor
           expression="pkg_rep_utils.to_money_sep ( round ( rc.PART_SUM , 2 ) )"
           descriptiveExpression="PART_SUM" order="17" width="4000"/>
        </dataItem>
        <dataItem name="s_date_strax" datatype="date" oracleDatatype="date"
         columnOrder="38" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="S Date Strax">
          <dataDescriptor expression="trunc ( pc.START_DATE )"
           descriptiveExpression="S_DATE_STRAX" order="20"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="e_date_strax" datatype="date" oracleDatatype="date"
         columnOrder="39" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="E Date Strax">
          <dataDescriptor expression="trunc ( pc.END_DATE )"
           descriptiveExpression="E_DATE_STRAX" order="21"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="s_date_waiting" datatype="date" oracleDatatype="date"
         columnOrder="40" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="S Date Waiting">
          <dataDescriptor expression="trunc ( pp.START_DATE )"
           descriptiveExpression="S_DATE_WAITING" order="22"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="days_waiting" oracleDatatype="number" columnOrder="41"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Days Waiting">
          <dataDescriptor
           expression="trunc ( pp.waiting_period_end_date ) - trunc ( pp.START_DATE ) + 1"
           descriptiveExpression="DAYS_WAITING" order="23"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="waiting_period_end_date" datatype="date"
         oracleDatatype="date" columnOrder="42" width="9" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Waiting Period End Date">
          <dataDescriptor expression="trunc ( pp.waiting_period_end_date )"
           descriptiveExpression="WAITING_PERIOD_END_DATE" order="24"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="is_in_waiting_period" oracleDatatype="number"
         columnOrder="43" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Is In Waiting Period">
          <dataDescriptor
           expression="nvl ( Pkg_Policy.is_in_waiting_period ( pp.policy_id , pp.waiting_period_id , pp.start_date ) , 0 )"
           descriptiveExpression="IS_IN_WAITING_PERIOD" order="28"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="dog_dest" oracleDatatype="number" columnOrder="44"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Dog Dest">
          <dataDescriptor
           expression="round ( CEIL ( MONTHS_BETWEEN ( NVL ( trunc ( pp.END_DATE ) , SYSDATE ) , NVL ( pp.START_DATE , SYSDATE ) ) / 12 ) + ( ( MONTHS_BETWEEN ( NVL ( pp.END_DATE , SYSDATE ) , NVL ( pp.START_DATE , SYSDATE ) ) - ( 12 * CEIL ( MONTHS_BETWEEN ( NVL ( pp.END_DATE , SYSDATE ) , NVL ( pp.START_DATE , SYSDATE ) ) / 12 ) ) ) / 100 ) , 2 )"
           descriptiveExpression="DOG_DEST" order="29" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_2" parentGroup="G_BORDERO_TYPE" parentColumn="RE_BORDERO_ID"
     childQuery="Q_BORDERO_LINE" childColumn="RE_BORDERO_ID1" condition="eq"
     sqlClause="where"/>
  </data>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>


<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:x="urn:schemas-microsoft-com:office:excel"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Excel.Sheet>
<meta name=Generator content="Microsoft Excel 11">
<link rel=File-List href="bordero.files/filelist.xml">
<link rel=Edit-Time-Data href="bordero.files/editdata.mso">
<link rel=OLE-Object-Data href="bordero.files/oledata.mso">
<!--[if !mso]>
<style>
v\:* {behavior:url(#default#VML);}
o\:* {behavior:url(#default#VML);}
x\:* {behavior:url(#default#VML);}
.shape {behavior:url(#default#VML);}
</style>
<![endif]--><!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>GeneralCologne Re</o:Author>
  <o:LastAuthor>skushenko</o:LastAuthor>
  <o:LastPrinted>2007-06-05T12:30:12Z</o:LastPrinted>
  <o:Created>2002-01-16T13:42:01Z</o:Created>
  <o:LastSaved>2007-06-05T12:32:08Z</o:LastSaved>
  <o:Company>GeneralCologne Re</o:Company>
  <o:Version>11.8122</o:Version>
 </o:DocumentProperties>
</xml><![endif]-->
<style>
<!--table
	{mso-displayed-decimal-separator:"\,";
	mso-displayed-thousand-separator:" ";}
@page
	{mso-footer-data:"&Ц&6Page &С&П&6&Д";
	margin:.24in .39in .39in .28in;
	mso-header-margin:.24in;
	mso-footer-margin:.28in;
	mso-page-orientation:landscape;}
.font6
	{color:windowtext;
	font-size:14.0pt;
	font-weight:700;
	font-style:normal;
	text-decoration:none;
	font-family:Univers;
	mso-generic-font-family:auto;
	mso-font-charset:0;}
.font7
	{color:windowtext;
	font-size:14.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Univers;
	mso-generic-font-family:auto;
	mso-font-charset:204;}
.font8
	{color:windowtext;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Univers;
	mso-generic-font-family:auto;
	mso-font-charset:204;}
.font17
	{color:windowtext;
	font-size:8.0pt;
	font-weight:400;
	font-style:italic;
	text-decoration:none;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;}
.font18
	{color:windowtext;
	font-size:8.0pt;
	font-weight:400;
	font-style:italic;
	text-decoration:none;
	font-family:Univers;
	mso-generic-font-family:auto;
	mso-font-charset:204;}
tr
	{mso-height-source:auto;}
col
	{mso-width-source:auto;}
br
	{mso-data-placement:same-cell;}
.style0
	{mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	white-space:nowrap;
	mso-rotate:0;
	mso-background-source:auto;
	mso-pattern:auto;
	color:windowtext;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Univers;
	mso-generic-font-family:auto;
	mso-font-charset:0;
	border:none;
	mso-protection:locked visible;
	mso-style-name:Обычный;
	mso-style-id:0;}
.style20
	{mso-number-format:0%;
	mso-style-name:Процентный;
	mso-style-id:5;}
td
	{mso-style-parent:style0;
	padding:0px;
	mso-ignore:padding;
	color:windowtext;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Univers;
	mso-generic-font-family:auto;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	border:none;
	mso-background-source:auto;
	mso-pattern:auto;
	mso-protection:locked visible;
	white-space:nowrap;
	mso-rotate:0;}
.xl24
	{mso-style-parent:style0;
	text-align:center;
	vertical-align:top;}
.xl25
	{mso-style-parent:style0;
	text-align:center;
	vertical-align:top;
	white-space:normal;}
.xl26
	{mso-style-parent:style0;
	font-size:8.0pt;
	text-align:center;
	vertical-align:top;}
.xl27
	{mso-style-parent:style0;
	mso-number-format:Standard;
	text-align:center;
	vertical-align:top;}
.xl28
	{mso-style-parent:style0;
	text-align:left;
	vertical-align:top;
	border-top:none;
	border-right:none;
	border-bottom:none;
	border-left:.5pt solid windowtext;}
.xl29
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-weight:700;
	text-align:left;
	vertical-align:top;}
.xl30
	{mso-style-parent:style0;
	text-align:left;
	vertical-align:top;}
.xl31
	{mso-style-parent:style0;
	font-family:Univers;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:left;
	vertical-align:top;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
.xl32
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-family:Univers;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:left;
	vertical-align:top;}
.xl33
	{mso-style-parent:style0;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:none;
	border-bottom:1.0pt solid windowtext;
	border-left:none;}
.xl34
	{mso-style-parent:style0;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:none;
	border-left:none;}
.xl35
	{mso-style-parent:style0;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:none;
	border-bottom:none;
	border-left:.5pt solid windowtext;}
.xl36
	{mso-style-parent:style0;
	font-size:10.0pt;
	font-style:italic;
	font-family:Arial, sans-serif;
	mso-font-charset:0;
	mso-number-format:"\@";
	text-align:center;
	vertical-align:top;
	mso-protection:unlocked visible;
	white-space:normal;}
.xl37
	{mso-style-parent:style0;
	font-size:14.0pt;
	text-align:center;
	vertical-align:top;}
.xl38
	{mso-style-parent:style0;
	font-size:14.0pt;
	text-align:left;
	vertical-align:top;}
.xl39
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	white-space:normal;}
.xl40
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	white-space:normal;}
.xl41
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:none;
	border-bottom:1.0pt solid windowtext;
	border-left:none;
	white-space:normal;}
.xl42
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-style:italic;
	font-family:Arial, sans-serif;
	mso-font-charset:0;
	mso-number-format:"\@";
	text-align:center;
	vertical-align:top;
	mso-protection:unlocked visible;}
.xl43
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-family:Univers;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:left;
	vertical-align:top;}
.xl44
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:0;
	text-align:left;
	vertical-align:top;}
.xl45
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-family:Univers;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:left;
	vertical-align:top;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
.xl46
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid black;
	border-bottom:none;
	border-left:none;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl47
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:.5pt solid black;
	border-right:.5pt solid black;
	border-bottom:none;
	border-left:none;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl48
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid black;
	border-bottom:none;
	border-left:none;
	white-space:normal;}
.xl49
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid black;
	border-bottom:none;
	border-left:none;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl50
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid black;
	border-bottom:none;
	border-left:none;
	white-space:normal;}
.xl51
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid black;
	border-bottom:none;
	border-left:none;
	background:yellow;
	mso-pattern:auto none;}
.xl52
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid black;
	border-bottom:none;
	border-left:none;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl53
	{mso-style-parent:style0;
	font-size:6.0pt;
	font-weight:700;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid black;
	border-bottom:1.0pt solid windowtext;
	border-left:none;}
.xl54
	{mso-style-parent:style0;
	font-size:6.0pt;
	font-weight:700;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid black;
	border-bottom:1.0pt solid black;
	border-left:none;}
.xl55
	{mso-style-parent:style0;
	font-size:6.0pt;
	font-weight:700;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid black;
	border-bottom:1.0pt solid black;
	border-left:none;}
.xl56
	{mso-style-parent:style0;
	font-size:9.0pt;
	font-weight:700;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:1.0pt solid windowtext;
	white-space:normal;}
.xl57
	{mso-style-parent:style0;
	font-size:8.0pt;
	mso-number-format:"\@";
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:1.0pt solid windowtext;}
.xl58
	{mso-style-parent:style0;
	font-size:8.0pt;
	text-align:left;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
.xl59
	{mso-style-parent:style0;
	font-size:8.0pt;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
.xl60
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-family:Arial, sans-serif;
	mso-font-charset:0;
	mso-number-format:"Short Date";
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	mso-protection:unlocked visible;}
.xl61
	{mso-style-parent:style0;
	font-size:8.0pt;
	mso-number-format:"Short Date";
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
.xl62
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-family:"Arial Cyr";
	mso-generic-font-family:auto;
	mso-font-charset:204;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
.xl63
	{mso-style-parent:style0;
	font-size:8.0pt;
	mso-number-format:Standard;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
.xl64
	{mso-style-parent:style0;
	font-size:8.0pt;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:1.0pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
.xl65
	{mso-style-parent:style0;
	font-size:9.0pt;
	font-weight:700;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:1.0pt solid windowtext;
	white-space:normal;}
.xl66
	{mso-style-parent:style0;
	font-size:8.0pt;
	mso-number-format:"\@";
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:1.0pt solid windowtext;}
.xl67
	{mso-style-parent:style0;
	font-size:8.0pt;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:none;
	border-left:none;}
.xl68
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-family:"Arial Cyr";
	mso-generic-font-family:auto;
	mso-font-charset:204;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
.xl69
	{mso-style-parent:style0;
	font-size:8.0pt;
	mso-number-format:Standard;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:none;
	border-left:none;}
.xl70
	{mso-style-parent:style0;
	font-size:8.0pt;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
.xl71
	{mso-style-parent:style0;
	font-size:8.0pt;
	text-align:center;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid windowtext;
	border-left:.5pt solid windowtext;}
.xl72
	{mso-style-parent:style0;
	font-size:8.0pt;
	mso-number-format:Standard;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid windowtext;
	border-left:none;}
.xl73
	{mso-style-parent:style0;
	font-size:8.0pt;
	mso-number-format:Standard;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid windowtext;
	border-left:none;}
.xl74
	{mso-style-parent:style20;
	font-size:8.0pt;
	mso-number-format:Percent;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid windowtext;
	border-left:none;}
.xl75
	{mso-style-parent:style0;
	font-size:8.0pt;
	mso-number-format:Fixed;
	text-align:center;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid windowtext;
	border-left:none;}
.xl76
	{mso-style-parent:style0;
	font-size:9.0pt;
	font-weight:700;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:none;
	border-bottom:1.0pt solid windowtext;
	border-left:1.0pt solid windowtext;
	white-space:normal;}
.xl77
	{mso-style-parent:style0;
	font-size:8.0pt;
	mso-number-format:"\@";
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid windowtext;
	border-left:1.0pt solid windowtext;}
.xl78
	{mso-style-parent:style0;
	font-size:8.0pt;
	text-align:left;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid windowtext;
	border-left:none;}
.xl79
	{mso-style-parent:style0;
	font-size:8.0pt;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid windowtext;
	border-left:none;}
.xl80
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-family:Arial, sans-serif;
	mso-font-charset:0;
	mso-number-format:"Short Date";
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid windowtext;
	border-left:none;
	mso-protection:unlocked visible;}
.xl81
	{mso-style-parent:style0;
	font-size:8.0pt;
	mso-number-format:"Short Date";
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid windowtext;
	border-left:none;}
.xl82
	{mso-style-parent:style0;
	font-size:8.0pt;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid windowtext;
	border-left:none;}
.xl83
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-family:"Arial Cyr";
	mso-generic-font-family:auto;
	mso-font-charset:204;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid windowtext;
	border-left:none;}
.xl84
	{mso-style-parent:style0;
	font-size:8.0pt;
	mso-number-format:Standard;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid windowtext;
	border-left:none;}
.xl85
	{mso-style-parent:style0;
	font-size:8.0pt;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:1.0pt solid windowtext;
	border-bottom:1.0pt solid windowtext;
	border-left:none;}
.xl86
	{mso-style-parent:style0;
	font-size:9.0pt;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:1.0pt solid windowtext;
	border-bottom:none;
	border-left:1.0pt solid windowtext;
	white-space:normal;}
.xl87
	{mso-style-parent:style0;
	font-size:9.0pt;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:1.0pt solid windowtext;
	border-bottom:none;
	border-left:1.0pt solid windowtext;
	white-space:normal;}
.xl88
	{mso-style-parent:style0;
	font-size:9.0pt;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:1.0pt solid windowtext;
	border-bottom:1.0pt solid black;
	border-left:1.0pt solid windowtext;
	white-space:normal;}
.xl89
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid black;
	border-bottom:none;
	border-left:1.0pt solid windowtext;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl90
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid black;
	border-bottom:1.0pt solid black;
	border-left:1.0pt solid windowtext;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl91
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid black;
	border-bottom:none;
	border-left:.5pt solid black;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl92
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid black;
	border-bottom:1.0pt solid black;
	border-left:.5pt solid black;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl93
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:none;
	border-left:.5pt solid black;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl94
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid black;
	border-left:.5pt solid black;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl95
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid black;
	border-bottom:none;
	border-left:.5pt solid windowtext;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl96
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid black;
	border-bottom:1.0pt solid black;
	border-left:.5pt solid windowtext;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl97
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid black;
	border-right:.5pt solid black;
	border-bottom:none;
	border-left:.5pt solid black;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl98
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid black;
	border-bottom:none;
	border-left:.5pt solid black;
	white-space:normal;}
.xl99
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid black;
	border-bottom:1.0pt solid black;
	border-left:.5pt solid black;
	white-space:normal;}
.xl100
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:none;
	border-bottom:.5pt solid black;
	border-left:.5pt solid black;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl101
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid black;
	border-bottom:.5pt solid black;
	border-left:none;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl102
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	mso-number-format:Standard;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:none;
	border-left:.5pt solid black;
	white-space:normal;}
.xl103
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	mso-number-format:Standard;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid black;
	border-left:.5pt solid black;
	white-space:normal;}
.xl104
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:none;
	border-left:.5pt solid windowtext;
	white-space:normal;}
.xl105
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:1.0pt solid black;
	border-left:.5pt solid windowtext;
	white-space:normal;}
.xl106
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:1.0pt solid windowtext;
	border-right:1.0pt solid windowtext;
	border-bottom:none;
	border-left:.5pt solid windowtext;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
.xl107
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-weight:700;
	font-style:italic;
	font-family:NTHarmonica;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:1.0pt solid windowtext;
	border-bottom:1.0pt solid black;
	border-left:.5pt solid windowtext;
	background:yellow;
	mso-pattern:auto none;
	white-space:normal;}
-->
</style>
<!--[if gte mso 9]><xml>
 <x:ExcelWorkbook>
  <x:ExcelWorksheets>
   <x:ExcelWorksheet>
    <x:Name>A</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>285</x:DefaultRowHeight>
     <x:TransitionExpressionEvaluation/>
     <x:TransitionExpressionEvaluation/>
     <x:StandardWidth>2496</x:StandardWidth>
     <x:Print>
      <x:ValidPrinterInfo/>
      <x:PaperSizeIndex>9</x:PaperSizeIndex>
      <x:Scale>65</x:Scale>
      <x:HorizontalResolution>600</x:HorizontalResolution>
      <x:VerticalResolution>600</x:VerticalResolution>
     </x:Print>
     <x:CodeName>Лист1</x:CodeName>
     <x:PageBreakZoom>100</x:PageBreakZoom>
     <x:Selected/>
     <x:GridlineColorIndex>8</x:GridlineColorIndex>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
  </x:ExcelWorksheets>
  <x:WindowHeight>8895</x:WindowHeight>
  <x:WindowWidth>12120</x:WindowWidth>
  <x:WindowTopX>360</x:WindowTopX>
  <x:WindowTopY>210</x:WindowTopY>
  <x:ProtectStructure>False</x:ProtectStructure>
  <x:ProtectWindows>False</x:ProtectWindows>
 </x:ExcelWorkbook>
 <x:ExcelName>
  <x:Name>_FilterDatabase</x:Name>
  <x:Hidden/>
  <x:SheetIndex>1</x:SheetIndex>
  <x:Formula>=A!$B$10:$AU$10</x:Formula>
 </x:ExcelName>
 <x:ExcelName>
  <x:Name>Print_Titles_MI</x:Name>
  <x:SheetIndex>1</x:SheetIndex>
  <x:Formula>=A!#REF!</x:Formula>
 </x:ExcelName>
 <x:ExcelName>
  <x:Name>Print_Area</x:Name>
  <x:SheetIndex>1</x:SheetIndex>
  <x:Formula>=A!$A$1:$AV$13</x:Formula>
 </x:ExcelName>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="1074" fillcolor="none [9]">
  <v:fill color="none [9]"/>
 </o:shapedefaults></xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body link=blue vlink=purple class=xl24>

<rw:foreach id="G_BORDERO" src="G_BORDERO">

<table x:str border=0 cellpadding=0 cellspacing=0 width=3219 style='border-collapse:
 collapse;table-layout:fixed;width:2419pt'>
 <col class=xl24 width=33 style='mso-width-source:userset;mso-width-alt:1056;
 width:25pt'>
 <col class=xl25 width=143 style='mso-width-source:userset;mso-width-alt:4576;
 width:107pt'>
 <col class=xl24 width=57 style='mso-width-source:userset;mso-width-alt:1824;
 width:43pt'>
 <col class=xl24 width=75 style='mso-width-source:userset;mso-width-alt:2400;
 width:56pt'>
 <col class=xl24 width=59 style='mso-width-source:userset;mso-width-alt:1888;
 width:44pt'>
 <col class=xl24 width=152 style='mso-width-source:userset;mso-width-alt:4864;
 width:114pt'>
 <col class=xl24 width=85 style='mso-width-source:userset;mso-width-alt:2720;
 width:64pt'>
 <col class=xl24 width=83 style='mso-width-source:userset;mso-width-alt:2656;
 width:62pt'>
 <col class=xl24 width=93 style='mso-width-source:userset;mso-width-alt:2976;
 width:70pt'>
 <col class=xl24 width=79 style='mso-width-source:userset;mso-width-alt:2528;
 mso-outline-level:1;width:59pt'>
 <col class=xl24 width=73 style='mso-width-source:userset;mso-width-alt:2336;
 width:55pt'>
 <col class=xl24 width=79 style='mso-width-source:userset;mso-width-alt:2528;
 mso-outline-level:1;width:59pt'>
 <col class=xl24 width=39 style='mso-width-source:userset;mso-width-alt:1248;
 width:29pt'>
 <col class=xl24 width=126 style='mso-width-source:userset;mso-width-alt:4032;
 width:95pt'>
 <col class=xl24 width=54 style='mso-width-source:userset;mso-width-alt:1728;
 width:41pt'>
 <col class=xl24 width=60 span=2 style='mso-width-source:userset;mso-width-alt:
 1920;width:45pt'>
 <col class=xl24 width=60 style='mso-width-source:userset;mso-width-alt:1920;
 mso-outline-level:1;width:45pt'>
 <col class=xl24 width=60 style='mso-width-source:userset;mso-width-alt:1920;
 mso-outline-level:1;width:45pt'>
 <col class=xl24 width=44 style='mso-width-source:userset;mso-width-alt:1408;
 width:33pt'>
 <col class=xl24 width=64 style='mso-width-source:userset;mso-width-alt:2048;
 mso-outline-level:1;width:48pt'>
 <col class=xl24 width=71 style='mso-width-source:userset;mso-width-alt:2272;
 mso-outline-level:1;width:53pt'>
 <col class=xl24 width=58 style='mso-width-source:userset;mso-width-alt:1856;
 mso-outline-level:1;width:44pt'>
 <col class=xl26 width=104 style='mso-width-source:userset;mso-width-alt:3328;
 mso-outline-level:1;width:78pt'>
 <col class=xl24 width=69 style='mso-width-source:userset;mso-width-alt:2208;
 width:52pt'>
 <col class=xl24 width=71 style='mso-width-source:userset;mso-width-alt:2272;
 width:53pt'>
 <col class=xl24 width=74 style='mso-width-source:userset;mso-width-alt:2368;
 width:56pt'>
 <col class=xl24 width=0 style='display:none;mso-width-source:userset;
 mso-width-alt:1728'>
 <col class=xl24 width=0 span=4 style='display:none;mso-width-source:userset;
 mso-width-alt:2432'>
 <col class=xl24 width=76 span=5 style='mso-width-source:userset;mso-width-alt:
 2432;width:57pt'>
 <col class=xl24 width=86 style='mso-width-source:userset;mso-width-alt:2752;
 width:65pt'>
 <col class=xl24 width=68 style='mso-width-source:userset;mso-width-alt:2176;
 width:51pt'>
 <col class=xl24 width=53 style='mso-width-source:userset;mso-width-alt:1696;
 width:40pt'>
 <col class=xl24 width=62 style='mso-width-source:userset;mso-width-alt:1984;
 width:47pt'>
 <col class=xl24 width=77 style='mso-width-source:userset;mso-width-alt:2464;
 width:58pt'>
 <col class=xl24 width=75 span=2 style='mso-width-source:userset;mso-width-alt:
 2400;width:56pt'>
 <col class=xl27 width=66 style='mso-width-source:userset;mso-width-alt:2112;
 width:50pt'>
 <col class=xl24 width=66 style='mso-width-source:userset;mso-width-alt:2112;
 width:50pt'>
 <col class=xl24 width=94 style='mso-width-source:userset;mso-width-alt:3008;
 width:71pt'>
 <col class=xl24 width=14 style='mso-width-source:userset;mso-width-alt:448;
 width:11pt'>
 <col class=xl24 width=78 style='width:59pt'>
 <tr height=25 style='mso-outline-level:1;height:18.75pt'>
  <td height=25 class=xl28 width=33 style='height:18.75pt;width:25pt'><!--[if gte vml 1]><v:shapetype
   id="_x0000_t201" coordsize="21600,21600" o:spt="201" path="m,l,21600r21600,l21600,xe">
   <v:stroke joinstyle="miter"/>
   <v:path shadowok="f" o:extrusionok="f" strokeok="f" fillok="f"
    o:connecttype="rect"/>
   <o:lock v:ext="edit" shapetype="t"/>
  </v:shapetype><v:shape id="_x0000_s1071" type="#_x0000_t201" style='position:absolute;
   margin-left:0;margin-top:0;width:24.75pt;height:18.75pt;z-index:47;
   visibility:hidden' o:insetmode="auto">
   <o:lock v:ext="edit" rotation="t" text="t"/>
   <![if excel]><x:ClientData ObjectType="Drop">
    <x:MoveWithCells/>
    <x:SizeWithCells/>
    <x:PrintObject>False</x:PrintObject>
    <x:UIObj/>
    <x:Val>0</x:Val>
    <x:Min>0</x:Min>
    <x:Max>100</x:Max>
    <x:Inc>1</x:Inc>
    <x:Page>10</x:Page>
    <x:Dx>15</x:Dx>
    <x:Sel>4</x:Sel>
    <x:SelType>Single</x:SelType>
    <x:LCT>EzFilter</x:LCT>
    <x:DropStyle>Simple</x:DropStyle>
    <x:DropLines>8</x:DropLines>
    <x:WidthMin>162</x:WidthMin>
   </x:ClientData>
   <![endif]></v:shape><v:shape id="_x0000_s1072" type="#_x0000_t201" style='position:absolute;
   margin-left:0;margin-top:0;width:24.75pt;height:18.75pt;z-index:48;
   visibility:hidden' o:insetmode="auto">
   <o:lock v:ext="edit" rotation="t" text="t"/>
   <![if excel]><x:ClientData ObjectType="Drop">
    <x:MoveWithCells/>
    <x:SizeWithCells/>
    <x:PrintObject>False</x:PrintObject>
    <x:UIObj/>
    <x:Val>0</x:Val>
    <x:Min>0</x:Min>
    <x:Max>100</x:Max>
    <x:Inc>1</x:Inc>
    <x:Page>10</x:Page>
    <x:Dx>15</x:Dx>
    <x:Sel>4</x:Sel>
    <x:SelType>Single</x:SelType>
    <x:LCT>EzFilter</x:LCT>
    <x:DropStyle>Simple</x:DropStyle>
    <x:DropLines>8</x:DropLines>
    <x:WidthMin>162</x:WidthMin>
   </x:ClientData>
   <![endif]></v:shape><v:shape id="_x0000_s1073" type="#_x0000_t201" style='position:absolute;
   margin-left:0;margin-top:0;width:24.75pt;height:18.75pt;z-index:49;
   visibility:hidden' o:insetmode="auto">
   <o:lock v:ext="edit" rotation="t" text="t"/>
   <![if excel]><x:ClientData ObjectType="Drop">
    <x:MoveWithCells/>
    <x:SizeWithCells/>
    <x:PrintObject>False</x:PrintObject>
    <x:UIObj/>
    <x:Val>0</x:Val>
    <x:Min>0</x:Min>
    <x:Max>100</x:Max>
    <x:Inc>1</x:Inc>
    <x:Page>10</x:Page>
    <x:Dx>15</x:Dx>
    <x:Sel>4</x:Sel>
    <x:SelType>Single</x:SelType>
    <x:LCT>EzFilter</x:LCT>
    <x:DropStyle>Simple</x:DropStyle>
    <x:DropLines>8</x:DropLines>
    <x:WidthMin>162</x:WidthMin>
   </x:ClientData>
   <![endif]></v:shape><![endif]-->&nbsp;<a name="Print_Area"></a></td>
  <td class=xl29 colspan=4 width=334 style='mso-ignore:colspan;width:250pt'>Cedant
  Company / <font class="font7">Название компа</font><span style='display:none'><font
  class="font7">нии</font><font class="font6">:</font></span></td>
  <td class=xl31 width=152 style='width:114pt'><rw:field id="" src="CENDANT"></rw:field></td>
  <td class=xl24 width=85 style='width:64pt'></td>
  <td class=xl30 width=83 style='width:62pt'></td>
  <td class=xl32 colspan=6 width=489 style='mso-ignore:colspan;width:367pt'>Period
  / Отчетный период: <font class="font8"><span
  style='mso-spacerun:yes'> </span><rw:field id="" src="START_DATE"></rw:field>-<rw:field id="" src="END_DATE"></rw:field></font></td>
  <td class=xl24 width=54 style='width:41pt'></td>
  <td class=xl24 width=60 style='width:45pt'></td>
  <td class=xl24 width=60 style='width:45pt'></td>
  <td class=xl24 width=60 style='width:45pt'></td>
  <td class=xl24 width=60 style='width:45pt'></td>
  <td class=xl24 width=44 style='width:33pt'></td>
  <td class=xl24 width=64 style='width:48pt'></td>
  <td class=xl24 width=71 style='width:53pt'></td>
  <td class=xl24 width=58 style='width:44pt'></td>
  <td class=xl26 width=104 style='width:78pt'></td>
  <td class=xl24 width=69 style='width:52pt'></td>
  <td class=xl24 width=71 style='width:53pt'></td>
  <td class=xl24 width=74 style='width:56pt'></td>
  <td class=xl24 width=0></td>
  <td class=xl33 width=0>&nbsp;</td>
  <td class=xl33 width=0>&nbsp;</td>
  <td class=xl33 width=0>&nbsp;</td>
  <td class=xl33 width=0>&nbsp;</td>
  <td class=xl33 width=76 style='width:57pt'>&nbsp;</td>
  <td class=xl33 width=76 style='width:57pt'>&nbsp;</td>
  <td class=xl33 width=76 style='width:57pt'>&nbsp;</td>
  <td class=xl33 width=76 style='width:57pt'>&nbsp;</td>
  <td class=xl33 width=76 style='width:57pt'>&nbsp;</td>
  <td class=xl33 width=86 style='width:65pt'>&nbsp;</td>
  <td class=xl33 width=68 style='width:51pt'>&nbsp;</td>
  <td class=xl33 width=53 style='width:40pt'>&nbsp;</td>
  <td class=xl33 width=62 style='width:47pt'>&nbsp;</td>
  <td class=xl33 width=77 style='width:58pt'>&nbsp;</td>
  <td class=xl24 width=75 style='width:56pt'></td>
  <td class=xl24 width=75 style='width:56pt'></td>
  <td class=xl27 width=66 style='width:50pt'></td>
  <td class=xl24 width=66 style='width:50pt'></td>
  <td class=xl24 width=94 style='width:71pt'></td>
  <td class=xl34 width=14 style='width:11pt'>&nbsp;</td>
  <td class=xl24 width=78 style='width:59pt'></td>
 </tr>
 <tr height=19 style='mso-outline-level:1;height:14.25pt'>
  <td height=19 class=xl35 style='height:14.25pt'>&nbsp;</td>
  <td class=xl36></td>
  <td colspan=3 class=xl24 style='mso-ignore:colspan'></td>
  <td class=xl30></td>
  <td class=xl24></td>
  <td colspan=2 class=xl30 style='mso-ignore:colspan'></td>
  <td colspan=14 class=xl24 style='mso-ignore:colspan'></td>
  <td class=xl26></td>
  <td colspan=20 class=xl24 style='mso-ignore:colspan'></td>
  <td class=xl27></td>
  <td colspan=2 class=xl24 style='mso-ignore:colspan'></td>
  <td class=xl34>&nbsp;</td>
  <td class=xl24></td>
 </tr>
 <tr height=26 style='mso-outline-level:1;height:19.5pt'>
  <td height=26 class=xl28 style='height:19.5pt'>&nbsp;</td>
  <td class=xl29 colspan=4 style='mso-ignore:colspan'>Underwriter / <font
  class="font7">ФИО андеррайтера:</font></td>
  <td class=xl31>Гущин Р. Н.</td>
  <td class=xl37></td>
  <td class=xl38></td>
  <td class=xl32 colspan=4 style='mso-ignore:colspan'>Currency/ Валюта:<span
  style='mso-spacerun:yes'>  </span><font class="font8"><rw:field id="" src="BRIEF"></rw:field> / <rw:field id="" src="NAME"></rw:field></font></td>
  <td colspan=11 class=xl37 style='mso-ignore:colspan'></td>
  <td class=xl26></td>
  <td colspan=2 class=xl39 style='mso-ignore:colspan'></td>
  <td colspan=2 class=xl40 style='mso-ignore:colspan'></td>
  <td class=xl41 width=0>&nbsp;</td>
  <td class=xl41 width=0>&nbsp;</td>
  <td class=xl41 width=0>&nbsp;</td>
  <td class=xl41 width=0>&nbsp;</td>
  <td class=xl41 width=76 style='width:57pt'>&nbsp;</td>
  <td class=xl41 width=76 style='width:57pt'>&nbsp;</td>
  <td class=xl41 width=76 style='width:57pt'>&nbsp;</td>
  <td class=xl41 width=76 style='width:57pt'>&nbsp;</td>
  <td class=xl41 width=76 style='width:57pt'>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td colspan=2 class=xl24 style='mso-ignore:colspan'></td>
  <td class=xl27></td>
  <td colspan=2 class=xl24 style='mso-ignore:colspan'></td>
  <td class=xl34>&nbsp;</td>
  <td class=xl24></td>
 </tr>
 <tr height=25 style='mso-outline-level:1;height:18.75pt'>
  <td height=25 class=xl35 style='height:18.75pt'>&nbsp;</td>
  <td class=xl42></td>
  <td colspan=3 class=xl37 style='mso-ignore:colspan'></td>
  <td class=xl43>Reinsurance contract</td>
  <td class=xl37></td>
  <td class=xl38></td>
  <td class=xl44></td>
  <td colspan=14 class=xl37 style='mso-ignore:colspan'></td>
  <td class=xl26></td>
  <td colspan=2 class=xl39 style='mso-ignore:colspan'></td>
  <td colspan=2 class=xl40 style='mso-ignore:colspan'></td>
  <td colspan=4 class=xl39 style='mso-ignore:colspan'></td>
  <td colspan=5 class=xl39 style='mso-ignore:colspan'></td>
  <td colspan=7 class=xl24 style='mso-ignore:colspan'></td>
  <td class=xl27></td>
  <td colspan=2 class=xl24 style='mso-ignore:colspan'></td>
  <td class=xl34>&nbsp;</td>
  <td class=xl24></td>
 </tr>
 <tr height=25 style='mso-outline-level:1;height:18.75pt'>
  <td height=25 class=xl35 style='height:18.75pt'>&nbsp;</td>
  <td class=xl29 colspan=2 style='mso-ignore:colspan'>Treaty / <font
  class="font7">Договор:</font></td>
  <td colspan=2 class=xl37 style='mso-ignore:colspan'></td>
  <td class=xl45>“Individual Life Insurance includ<span style='display:none'>ing
  Dread Disease and Accidental Death benefits”</span></td>
  <td class=xl37></td>
  <td class=xl38></td>
  <td class=xl32 colspan=6 style='mso-ignore:colspan'>Country of Issue /
  Страна: <font class="font8">Russia / Россия</font></td>
  <td colspan=9 class=xl37 style='mso-ignore:colspan'></td>
  <td class=xl26></td>
  <td colspan=2 class=xl24 style='mso-ignore:colspan'></td>
  <td colspan=2 class=xl37 style='mso-ignore:colspan'></td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td class=xl33>&nbsp;</td>
  <td colspan=2 class=xl24 style='mso-ignore:colspan'></td>
  <td class=xl27></td>
  <td colspan=2 class=xl24 style='mso-ignore:colspan'></td>
  <td class=xl34>&nbsp;</td>
  <td class=xl24></td>
 </tr>
 <tr height=20 style='mso-outline-level:1;height:15.0pt'>
  <td height=20 class=xl35 style='height:15.0pt'>&nbsp;</td>
  <td class=xl25></td>
  <td colspan=21 class=xl24 style='mso-ignore:colspan'></td>
  <td class=xl26></td>
  <td colspan=20 class=xl24 style='mso-ignore:colspan'></td>
  <td class=xl27></td>
  <td colspan=2 class=xl24 style='mso-ignore:colspan'></td>
  <td class=xl34>&nbsp;</td>
  <td class=xl24></td>
 </tr>
 <tr height=42 style='height:31.5pt'>
  <td height=42 class=xl35 style='height:31.5pt'>&nbsp;</td>
  <td rowspan=3 class=xl86 width=143 style='border-bottom:1.0pt solid black;
  width:107pt'>&nbsp;</td>
  <td rowspan=2 class=xl89 width=57 style='border-bottom:1.0pt solid black;
  width:43pt'>Policy No. / <font class="font17">№ полиса</font></td>
  <td rowspan=2 class=xl91 width=75 style='border-bottom:1.0pt solid black;
  width:56pt'>Product name / <font class="font17">название продукта</font></td>
  <td rowspan=2 class=xl91 width=59 style='border-bottom:1.0pt solid black;
  width:44pt'>Product name / <font class="font17">название продукта</font></td>
  <td rowspan=2 class=xl93 width=152 style='border-bottom:1.0pt solid black;
  width:114pt'>Policy type (death / Acc. Death /Acc. Dismemb...) / <font
  class="font17">страховой риск</font></td>
  <td rowspan=2 class=xl95 width=85 style='border-bottom:1.0pt solid black;
  width:64pt'>Last Name / <font class="font17">фамилия</font></td>
  <td rowspan=2 class=xl91 width=83 style='border-bottom:1.0pt solid black;
  width:62pt'>First Name / <font class="font17">имя</font></td>
  <td rowspan=2 class=xl91 width=93 style='border-bottom:1.0pt solid black;
  width:70pt'>Patronymic /<font class="font17"> отчество</font></td>
  <td class=xl46 width=79 style='width:59pt'>ФИО</td>
  <td rowspan=2 class=xl91 width=73 style='border-bottom:1.0pt solid black;
  width:55pt'>Date of Birth /<font class="font17"> дата рождения</font></td>
  <td rowspan=2 class=xl91 width=79 style='border-bottom:1.0pt solid black;
  width:59pt'>Sex / <font class="font17">пол<span
  style='mso-spacerun:yes'> </span></font></td>
  <td rowspan=2 class=xl91 width=39 style='border-bottom:1.0pt solid black;
  width:29pt'>Sex / <font class="font17">пол<span
  style='mso-spacerun:yes'> </span></font></td>
  <td rowspan=2 class=xl91 width=126 style='border-bottom:1.0pt solid black;
  width:95pt'>Occupation <font class="font8">/ </font><font class="font18">профессия</font></td>
  <td rowspan=2 class=xl91 width=54 style='border-bottom:1.0pt solid black;
  width:41pt'>Effective date of alterations / <font class="font17">Дата
  изменений по договору</font></td>
  <td rowspan=2 class=xl91 width=60 style='border-bottom:1.0pt solid black;
  width:45pt'>Start Date / <font class="font17">начало страхования</font></td>
  <td rowspan=2 class=xl91 width=60 style='border-bottom:1.0pt solid black;
  width:45pt'>Expiry Date / <font class="font17">окончание страхования</font></td>
  <td class=xl46 width=60 style='width:45pt'>&nbsp;</td>
  <td class=xl46 width=60 style='width:45pt'>&nbsp;</td>
  <td rowspan=2 class=xl91 width=44 style='border-bottom:1.0pt solid black;
  width:33pt'>Duration / <font class="font17">cрок действия договора</font></td>
  <td rowspan=2 class=xl97 width=64 style='border-bottom:1.0pt solid black;
  width:48pt'>Waiting period_start date / <font class="font17">Начало
  выжидательного периода</font></td>
  <td rowspan=2 class=xl97 width=71 style='border-bottom:1.0pt solid black;
  width:53pt'>Waiting period _end date/ <font class="font17">Конец
  выжидательного периода</font></td>
  <td rowspan=2 class=xl97 width=58 style='border-bottom:1.0pt solid black;
  width:44pt'>Waiting period duration / <font class="font17">Длительность
  выжидательного периода</font></td>
  <td class=xl47 width=104 style='width:78pt'>периодичность оплаты</td>
  <td rowspan=2 class=xl91 width=69 style='border-bottom:1.0pt solid black;
  width:52pt'>Instalment payment period_start / <font class="font17">Начало
  оплачиваемого периода</font></td>
  <td rowspan=2 class=xl91 width=71 style='border-bottom:1.0pt solid black;
  width:53pt'>Instalment payment period_end/ <font class="font17">Конец
  оплачиваемого периода</font></td>
  <td rowspan=2 class=xl98 width=74 style='border-bottom:1.0pt solid black;
  width:56pt'>Original Benefit insured / <font class="font17"><span
  style='mso-spacerun:yes'> </span>Первоначальное страховое обеспечение под
  риском</font></td>
  <td rowspan=2 class=xl98 width=0 style='border-bottom:1.0pt solid black'>Reinsurance
  share/ <font class="font17"><span style='mso-spacerun:yes'> </span>Доля
  перестраховщика</font></td>
  <td rowspan=2 class=xl98 width=0 style='border-bottom:1.0pt solid black'>Initial
  benefit reinsured / <font class="font17"><span
  style='mso-spacerun:yes'> </span>Первоначальное перестрахованное страховое
  обеспечение</font></td>
  <td class=xl48 width=0>Benefit insuret at risk</td>
  <td class=xl48 width=0>тариф</td>
  <td rowspan=2 class=xl98 width=0 style='border-bottom:1.0pt solid black'>Basic
  reinsurance premium per annum / <font class="font17"><span
  style='mso-spacerun:yes'> </span>Годовая базисная ставка перестраховонной
  премии</font></td>
  <td rowspan=2 class=xl98 width=76 style='border-bottom:1.0pt solid black;
  width:57pt'>Reinsurance share/ <font class="font17"><span
  style='mso-spacerun:yes'> </span>Доля перестраховщика</font></td>
  <td rowspan=2 class=xl98 width=76 style='border-bottom:1.0pt solid black;
  width:57pt'>Initial benefit reinsured / <font class="font17"><span
  style='mso-spacerun:yes'> </span>Первоначальное перестрахованное страховое
  обеспечение</font></td>
  <td class=xl48 width=76 style='width:57pt'>Benefit insuret at risk</td>
  <td class=xl48 width=76 style='width:57pt'>тариф</td>
  <td rowspan=2 class=xl98 width=76 style='border-bottom:1.0pt solid black;
  width:57pt'>Basic reinsurance premium per annum / <font class="font17"><span
  style='mso-spacerun:yes'> </span>Годовая базисная ставка перестраховонной
  премии</font></td>
  <td colspan=2 class=xl100 width=154 style='border-right:.5pt solid black;
  border-left:none;width:116pt'>Medical extra reinsurancepremium per annum / <font
  class="font17">годовой повышающий коэффициентк ставке премии по медицинским
  показаниям</font></td>
  <td rowspan=2 class=xl91 width=53 style='border-bottom:1.0pt solid black;
  width:40pt'>Termination date of extra mode <font class="font17">/ дата
  окончания применения временного коэффициента</font></td>
  <td colspan=2 class=xl100 width=139 style='border-right:.5pt solid black;
  border-left:none;width:105pt'>Non-medical extra reinsurance premium per
  annum/ г<font class="font17">одовой повышающий коэффициентк ставке премии по
  немедицинским показаниям</font></td>
  <td rowspan=2 class=xl91 width=75 style='border-bottom:1.0pt solid black;
  width:56pt'>Termination date of extra mode <font class="font17">/ дата
  окончания применения временного коэффициента</font></td>
  <td rowspan=2 class=xl98 width=75 style='border-bottom:1.0pt solid black;
  width:56pt'>Modal factors <font class="font17">/ Коэффициенты рассрочки</font></td>
  <td rowspan=2 class=xl102 width=66 style='border-bottom:1.0pt solid black;
  width:50pt'>Reinsurance premium per period / <font class="font17">Перестраховочная
  премия за период</font></td>
  <td rowspan=2 class=xl104 width=66 style='border-bottom:1.0pt solid black;
  width:50pt'>Status (QS,Surplus,Fac) / <font class="font17">Статус (квота,
  эксцедент суммы, факультатив)</font></td>
  <td rowspan=2 class=xl106 width=94 style='border-bottom:1.0pt solid black;
  width:71pt'>Comments / <font class="font17">Комментарии</font></td>
  <td class=xl34>&nbsp;</td>
  <td class=xl24></td>
 </tr>
 <tr height=97 style='mso-height-source:userset;height:72.75pt'>
  <td height=97 class=xl35 style='height:72.75pt'>&nbsp;</td>
  <td class=xl49 width=79 style='width:59pt'>&nbsp;</td>
  <td class=xl49 width=60 style='width:45pt'>&nbsp;</td>
  <td class=xl49 width=60 style='width:45pt'>&nbsp;</td>
  <td class=xl49 width=104 style='width:78pt'>&nbsp;</td>
  <td class=xl50 width=0>Страховое обеспечение под риском</td>
  <td class=xl50 width=0>&nbsp;</td>
  <td class=xl50 width=76 style='width:57pt'>Страховое обеспечение под риском</td>
  <td class=xl50 width=76 style='width:57pt'>&nbsp;</td>
  <td class=xl51>%</td>
  <td class=xl52 width=68 style='width:51pt'>‰</td>
  <td class=xl51>%</td>
  <td class=xl52 width=77 style='width:58pt'>‰</td>
  <td class=xl34>&nbsp;</td>
  <td class=xl24></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl35 style='height:15.0pt'>&nbsp;</td>
  <td class=xl53 x:num>1</td>
  <td class=xl54 x:num>2</td>
  <td class=xl54 x:num>3</td>
  <td class=xl54 x:num>4</td>
  <td class=xl54 x:num>5</td>
  <td class=xl54 x:num>6</td>
  <td class=xl54 x:num>7</td>
  <td class=xl55 x:num>8</td>
  <td class=xl54 x:num>9</td>
  <td class=xl54 x:num>10</td>
  <td class=xl54 x:num>11</td>
  <td class=xl54 x:num>12</td>
  <td class=xl54 x:num>13</td>
  <td class=xl54 x:num>14</td>
  <td class=xl54 x:num>15</td>
  <td class=xl55>&nbsp;</td>
  <td class=xl55>&nbsp;</td>
  <td class=xl54 x:num>16</td>
  <td class=xl54 x:num>17</td>
  <td class=xl54 x:num>18</td>
  <td class=xl54 x:num>19</td>
  <td class=xl55 x:num>20</td>
  <td class=xl54 x:num>21</td>
  <td class=xl54 x:num>22</td>
  <td class=xl54 x:num>23</td>
  <td class=xl54 x:num>24</td>
  <td class=xl54 x:num>25</td>
  <td class=xl55 x:num>26</td>
  <td class=xl55 x:num>27</td>
  <td class=xl54 x:num>28</td>
  <td class=xl54 x:num>24</td>
  <td class=xl54 x:num>25</td>
  <td class=xl55 x:num>26</td>
  <td class=xl55 x:num>27</td>
  <td class=xl54 x:num>28</td>
  <td class=xl55 x:num>29</td>
  <td class=xl55 x:num>30</td>
  <td class=xl54 x:num>31</td>
  <td class=xl55 x:num>32</td>
  <td class=xl55 x:num>33</td>
  <td class=xl54 x:num>34</td>
  <td class=xl54 x:num>35</td>
  <td class=xl54 x:num>36</td>
  <td class=xl54 x:num>37</td>
  <td class=xl54 x:num>38</td>
  <td class=xl34>&nbsp;</td>
  <td class=xl24></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl24 style='height:15.0pt'></td>
  <td class=xl56 id="_x0000_s1025" x:autofilter="all"
  x:autofilterrange="$B$10:$AU$10" width=143 style='width:107pt'>&nbsp;</td>
  <td class=xl57 id="_x0000_s1026" x:autofilter="all">&nbsp;</td>
  <td class=xl58 id="_x0000_s1027" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1028" x:autofilter="all">&nbsp;</td>
  <td class=xl58 id="_x0000_s1029" x:autofilter="all">&nbsp;</td>
  <td class=xl58 id="_x0000_s1030" x:autofilter="all">&nbsp;</td>
  <td class=xl58 id="_x0000_s1031" x:autofilter="all">&nbsp;</td>
  <td class=xl58 id="_x0000_s1032" x:autofilter="all">&nbsp;</td>
  <td class=xl58 id="_x0000_s1033" x:autofilter="all">&nbsp;</td>
  <td class=xl60 id="_x0000_s1034" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1035" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1036" x:autofilter="all">&nbsp;</td>
  <td class=xl58 id="_x0000_s1037" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1038" x:autofilter="all">&nbsp;</td>
  <td class=xl61 id="_x0000_s1039" x:autofilter="all">&nbsp;</td>
  <td class=xl61 id="_x0000_s1040" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1041" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1042" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1043" x:autofilter="all">&nbsp;</td>
  <td class=xl61 id="_x0000_s1044" x:autofilter="all">&nbsp;</td>
  <td class=xl61 id="_x0000_s1045" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1046" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1047" x:autofilter="all">&nbsp;</td>
  <td class=xl61 id="_x0000_s1048" x:autofilter="all">&nbsp;</td>
  <td class=xl61 id="_x0000_s1049" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1050" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1051" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1052" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1053" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1054" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1055" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1056" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1057" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1058" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1059" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1060" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1061" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1062" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1063" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1064" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1065" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1066" x:autofilter="all">&nbsp;</td>
  <td class=xl62 id="_x0000_s1067" x:autofilter="all">&nbsp;</td>
  <td class=xl63 id="_x0000_s1068" x:autofilter="all">&nbsp;</td>
  <td class=xl59 id="_x0000_s1069" x:autofilter="all">&nbsp;</td>
  <td class=xl64 id="_x0000_s1070" x:autofilter="all">&nbsp;</td>
  <td colspan=2 class=xl24 style='mso-ignore:colspan'></td>
 </tr>
<rw:foreach id="G_BORDERO_TYPE" src="G_BORDERO_TYPE">

 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl24 style='height:15.0pt'></td>
  <td class=xl65 width=143 style='width:107pt'><rw:field id="" src="NAME1"></rw:field></td>
  <td class=xl66>&nbsp;</td>
  <td class=xl58>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl58>&nbsp;</td>
  <td class=xl58>&nbsp;</td>
  <td class=xl58>&nbsp;</td>
  <td class=xl58>&nbsp;</td>
  <td class=xl58>&nbsp;</td>
  <td class=xl60>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl58>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl61>&nbsp;</td>
  <td class=xl61>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl61>&nbsp;</td>
  <td class=xl61>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl67>&nbsp;</td>
  <td class=xl61>&nbsp;</td>
  <td class=xl61>&nbsp;</td>
  <td class=xl67>&nbsp;</td>
  <td class=xl67>&nbsp;</td>
  <td class=xl67>&nbsp;</td>
  <td class=xl67>&nbsp;</td>
  <td class=xl67>&nbsp;</td>
  <td class=xl67>&nbsp;</td>
  <td class=xl67>&nbsp;</td>
  <td class=xl67>&nbsp;</td>
  <td class=xl67>&nbsp;</td>
  <td class=xl67>&nbsp;</td>
  <td class=xl67>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl68>&nbsp;</td>
  <td class=xl69>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl64>&nbsp;</td>
  <td colspan=2 class=xl24 style='mso-ignore:colspan'></td>
 </tr>
<rw:foreach id="G_BORDERO_LINE" src="G_BORDERO_LINE">
<rw:getValue id="IS_IN_WAITING_PERIOD" src="IS_IN_WAITING_PERIOD" formatMask="999999990.99"/>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl24 style='height:15.0pt'></td>
  <td class=xl65 width=143 style='width:107pt'>&nbsp;</td>
  <td class=xl66><rw:field id="" src="NUM_POL"></rw:field></td>
  <td class=xl58><rw:field id="" src="BRIEF2"></rw:field></td>
  <td class=xl59><rw:field id="" src="DESCRIPTION"></rw:field></td>
  <td class=xl58><rw:field id="" src="PROGR"></rw:field></td>
  <td class=xl58><rw:field id="" src="FAMIL"></rw:field></td>
  <td class=xl58><rw:field id="" src="FIRST_NAME"></rw:field></td>
  <td class=xl58><rw:field id="" src="MIDDLE_NAME"></rw:field></td>
  <td class=xl58><rw:field id="" src="FIO"></rw:field></td>
  <td class=xl60><rw:field id="" src="DATE_OF_BIRTH"></rw:field></td>
  <td class=xl59><rw:field id="" src="POL_D"></rw:field></td>
  <td class=xl59><rw:field id="" src="POL"></rw:field></td>
  <td class=xl58><rw:field id="" src="NOTE"></rw:field></td>
  <td class=xl59>&nbsp;</td>
  <td class=xl61><rw:field id="" src="S_DATE_STRAX"></rw:field></td>
  <td class=xl61><rw:field id="" src="E_DATE_STRAX"></rw:field></td>
  <td class=xl59>&nbsp;</td>
  <td class=xl59>&nbsp;</td>
  <td class=xl59><rw:field id="" src="DOG_DEST"></rw:field></td>
  <td class=xl61><%if (Double.valueOf(IS_IN_WAITING_PERIOD).doubleValue() == 0) {%>&nbsp;
    <%} else {%><rw:field id="" src="S_DATE_WAITING"></rw:field><%}%> </td>
  <td class=xl61><%if (Double.valueOf(IS_IN_WAITING_PERIOD).doubleValue() == 0) {%>&nbsp;
    <%} else {%><rw:field id="" src="WAITING_PERIOD_END_DATE"></rw:field><%}%> </td>
  <td class=xl70><%if (Double.valueOf(IS_IN_WAITING_PERIOD).doubleValue() == 0) {%>&nbsp;
    <%} else {%><rw:field id="" src="DAYS_WAITING"></rw:field><%}%> </td>
  <td class=xl71><rw:field id="" src="PER_OPL"></rw:field></td>
  <td class=xl61><rw:field id="" src="OPL_S"></rw:field></td>
  <td class=xl61><rw:field id="" src="OPL_E"></rw:field></td>
  <td class=xl72><rw:field id="" src="FIRST_INS_GUARANTEE"></rw:field></td>
  <td class=xl73><rw:field id="" src="PART_PERC"></rw:field></td>
  <td class=xl73><rw:field id="" src="REINS_GUARANTEE"></rw:field></td>
  <td class=xl73><rw:field id="" src="INS_GUARANTEE"></rw:field></td>
  <td class=xl73><rw:field id="" src="RE_TARIFF"></rw:field></td>  
  <td class=xl73><rw:field id="" src="FIRST_INS_GUARANTEE"></rw:field></td>
  <td class=xl73><rw:field id="" src="PART_PERC"></rw:field></td>
  <td class=xl73><rw:field id="" src="REINS_GUARANTEE"></rw:field></td>
  <td class=xl73><rw:field id="" src="INS_GUARANTEE"></rw:field></td>
  <td class=xl73><rw:field id="" src="RE_TARIFF"></rw:field></td>  
  <td class=xl84><rw:field id="" src="BR_PREM28"></rw:field></td>
  <td class=xl59><rw:field id="" src="K_COEF_M"></rw:field></td>
  <td class=xl59><rw:field id="" src="S_COEF_M"></rw:field></td>
  <td class=xl59>&nbsp;</td>
  <td class=xl59><rw:field id="" src="K_COEF_NM"></rw:field></td>
  <td class=xl59><rw:field id="" src="S_COEF_NM"></rw:field></td>
  <td class=xl59>&nbsp;</td>
  <td class=xl75><rw:field id="" src="K_DOWN_PAYMENT"></rw:field></td>
  <td class=xl84><rw:field id="" src="RE_PREMIUM"></rw:field></td>
  <td class=xl59>&nbsp;</td>
  <td class=xl64>&nbsp;</td>
  <td colspan=2 class=xl24 style='mso-ignore:colspan'></td>
 </tr>
</rw:foreach>

 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl24 style='height:15.0pt'></td>
  <td class=xl76 width=143 style='width:107pt'>Sum/Итог</td>
  <td class=xl77>&nbsp;</td>
  <td class=xl78>&nbsp;</td>
  <td class=xl79>&nbsp;</td>
  <td class=xl78>&nbsp;</td>
  <td class=xl78>&nbsp;</td>
  <td class=xl78>&nbsp;</td>
  <td class=xl78>&nbsp;</td>
  <td class=xl78>&nbsp;</td>
  <td class=xl80>&nbsp;</td>
  <td class=xl79>&nbsp;</td>
  <td class=xl79>&nbsp;</td>
  <td class=xl78>&nbsp;</td>
  <td class=xl79>&nbsp;</td>
  <td class=xl81>&nbsp;</td>
  <td class=xl81>&nbsp;</td>
  <td class=xl79>&nbsp;</td>
  <td class=xl79>&nbsp;</td>
  <td class=xl79>&nbsp;</td>
  <td class=xl81>&nbsp;</td>
  <td class=xl81>&nbsp;</td>
  <td class=xl79>&nbsp;</td>
  <td class=xl82>&nbsp;</td>
  <td class=xl81>&nbsp;</td>
  <td class=xl81>&nbsp;</td>
  <td class=xl82>&nbsp;</td>
  <td class=xl82>&nbsp;</td>
  <td class=xl82>&nbsp;</td>
  <td class=xl82>&nbsp;</td>
  <td class=xl82>&nbsp;</td>
  <td class=xl82>&nbsp;</td>
  <td class=xl82>&nbsp;</td>
  <td class=xl82>&nbsp;</td>
  <td class=xl82>&nbsp;</td>
  <td class=xl82>&nbsp;</td>
  <td class=xl82>&nbsp;</td>
  <td class=xl79>&nbsp;</td>
  <td class=xl79>&nbsp;</td>
  <td class=xl79>&nbsp;</td>
  <td class=xl79>&nbsp;</td>
  <td class=xl79>&nbsp;</td>
  <td class=xl79>&nbsp;</td>
  <td class=xl83>&nbsp;</td>
  <td class=xl84><rw:field id="" src="SUM_RE_PREMIUM"></rw:field></td>
  <td class=xl79>&nbsp;</td>
  <td class=xl85>&nbsp;</td>
  <td colspan=2 class=xl24 style='mso-ignore:colspan'></td>
 </tr>
</rw:foreach> 
 
 <![if supportMisalignedColumns]>
 <tr height=0 style='display:none'>
  <td width=33 style='width:25pt'></td>
  <td width=143 style='width:107pt'></td>
  <td width=57 style='width:43pt'></td>
  <td width=75 style='width:56pt'></td>
  <td width=59 style='width:44pt'></td>
  <td width=152 style='width:114pt'></td>
  <td width=85 style='width:64pt'></td>
  <td width=83 style='width:62pt'></td>
  <td width=93 style='width:70pt'></td>
  <td width=79 style='width:59pt'></td>
  <td width=73 style='width:55pt'></td>
  <td width=79 style='width:59pt'></td>
  <td width=39 style='width:29pt'></td>
  <td width=126 style='width:95pt'></td>
  <td width=54 style='width:41pt'></td>
  <td width=60 style='width:45pt'></td>
  <td width=60 style='width:45pt'></td>
  <td width=60 style='width:45pt'></td>
  <td width=60 style='width:45pt'></td>
  <td width=44 style='width:33pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=71 style='width:53pt'></td>
  <td width=58 style='width:44pt'></td>
  <td width=104 style='width:78pt'></td>
  <td width=69 style='width:52pt'></td>
  <td width=71 style='width:53pt'></td>
  <td width=74 style='width:56pt'></td>
  <td width=0></td>
  <td width=0></td>
  <td width=0></td>
  <td width=0></td>
  <td width=0></td>
  <td width=76 style='width:57pt'></td>
  <td width=76 style='width:57pt'></td>
  <td width=76 style='width:57pt'></td>
  <td width=76 style='width:57pt'></td>
  <td width=76 style='width:57pt'></td>
  <td width=86 style='width:65pt'></td>
  <td width=68 style='width:51pt'></td>
  <td width=53 style='width:40pt'></td>
  <td width=62 style='width:47pt'></td>
  <td width=77 style='width:58pt'></td>
  <td width=75 style='width:56pt'></td>
  <td width=75 style='width:56pt'></td>
  <td width=66 style='width:50pt'></td>
  <td width=66 style='width:50pt'></td>
  <td width=94 style='width:71pt'></td>
  <td width=14 style='width:11pt'></td>
  <td width=78 style='width:59pt'></td>
 </tr>
 <![endif]>
</table>

</rw:foreach>
</body>

</html>


</rw:report>

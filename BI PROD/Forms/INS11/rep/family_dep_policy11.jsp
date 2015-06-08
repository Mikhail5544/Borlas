<%@ taglib uri="/WEB-INF/lib/reports_tld.jar" prefix="rw" %> 
<%@ page language="java" import="java.io.*" errorPage="/rwerror.jsp" session="false" %>
<%@ page import="java.text.*" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report"> 
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="life_garmony_policy" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="afterpform" unitOfMeasurement="centimeter">
  <xmlSettings xmlTag="LIFE_GARMONY_POLICY" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_POLICY_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PH_BIRTH" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PA_DOC" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="NEXT_PAYS" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="MAIN_COVER_SUM" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="MAIN_COVER_PREM" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="MAIN_COVER" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="ITOGO_PREM" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="INSURER" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="POL_NUM" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="POL_HOLDER" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="TYPE_CONT" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="POL_ASS" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PH_DOC" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PA_BIRTH" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="FIRST_PAY" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="ADMIN_PAY" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="INSURER_INN" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PROGRAMMA" datatype="character" width="100"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_SYSDATE" datatype="character" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_NOTICE" datatype="character" width="100"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="CUR_POLICY" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PA_PERIODICH" datatype="character" width="100"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PA_CURATOR" datatype="character" width="100"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PA_TABNUM" datatype="character" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="WAITING_PERIOD_END_DATE" datatype="character"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PRINT_8_4" datatype="character"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PRINT_DATE_CHAR" datatype="character"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PA_ROW_PRIL" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PA_KOD_VAL" datatype="character" precision="10"
     defaultWidth="0" defaultHeight="0"/>
 <userParameter name="PA_KOD_VAL_UP" datatype="character" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_CNT_POVREZH" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_EXIST_DOP" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_EXIST_DOP_NS" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_EXIST_AVTOPR" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_CNT_DOP_PROGR" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_TEL_VRED" datatype="character" width="100"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_OSN_PROGR" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_DOP_PROGR" datatype="character" width="500"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="BRIEF_PRODUCT" datatype="character" width="100"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <systemParameter name="PRINTJOB" validationTrigger="printjobvalidtrigger"
    />
    <systemParameter name="MODE" validationTrigger="modevalidtrigger"/>
    <systemParameter name="ORIENTATION"
     validationTrigger="orientationvalidtrigger"/>
    <systemParameter name="DESNAME" validationTrigger="desnamevalidtrigger"/>
    <systemParameter name="DESTYPE" validationTrigger="destypevalidtrigger"/>
    <dataSource name="Q_1">
      <select>
      <![CDATA[
      
select years, start_date, end_date, brief from 
(select round(months_between(to_date(pc.end_date),pc.start_date)/12) years,
        pc.start_date,
        to_date(pc.end_date) end_date,
        plt.brief
from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc,

        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt
        
where pp.policy_id = :P_POLICY_ID
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id

      and plo.id = pc.t_prod_line_option_id
      and plo.product_line_id = pl.id
      and pl.product_line_type_id = plt.product_line_type_id
      --and plt.brief = 'RECOMMENDED'
and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'

 group by plt.brief, pc.start_date,  to_date(pc.end_date)) t
order by t.brief desc, t.years desc

]]>
      </select>
      <displayInfo x="2.01073" y="0.58198" width="1.77788" height="0.50788"/>
      <group name="G_years">
        <displayInfo x="1.00273" y="2.35986" width="3.78675" height="5.00063"
        />
        <dataItem name="brief" datatype="vchar2" columnOrder="63" width="30"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Brief">
          <dataDescriptor expression="brief" descriptiveExpression="BRIEF"
           order="4" width="30"/>
        </dataItem>
        <formula name="CF_year" source="cf_yearformula" datatype="character"
         width="20" precision="10" defaultWidth="100000" defaultHeight="10000"
         columnFlags="16" defaultLabel="Cf Year" breakOrder="none">
          <displayInfo x="0.00000" y="0.00000" width="0.00000"
           height="0.00000"/>
        </formula>
        <dataItem name="years" oracleDatatype="number" columnOrder="27"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Years">
          <dataDescriptor expression="years" descriptiveExpression="YEARS"
           order="1" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <formula name="CF_COVER_LIST" source="cf_srokformula"
         datatype="character" width="500" precision="10" defaultWidth="100000"
         defaultHeight="10000" columnFlags="16" defaultLabel="Cf Cover List"
         breakOrder="none">
          <displayInfo x="0.00000" y="0.00000" width="0.00000"
           height="0.00000"/>
        </formula>
        <formula name="CF_end_date" source="cf_end_dateformula"
         datatype="character" width="30" precision="10" defaultWidth="100000"
         defaultHeight="10000" columnFlags="16" defaultLabel="Cf End Date"
         breakOrder="none">
          <displayInfo x="0.00000" y="0.00000" width="0.00000"
           height="0.00000"/>
        </formula>
        <formula name="CF_start_date" source="cf_start_dateformula"
         datatype="character" width="30" precision="10" defaultWidth="100000"
         defaultHeight="10000" columnFlags="16" defaultLabel="Cf Start Date"
         breakOrder="none">
          <displayInfo x="0.00000" y="0.00000" width="0.00000"
           height="0.00000"/>
        </formula>
        <dataItem name="start_date" datatype="date" oracleDatatype="date"
         columnOrder="28" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Start Date">
          <dataDescriptor expression="start_date"
           descriptiveExpression="START_DATE" order="2" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="end_date" datatype="date" oracleDatatype="date"
         columnOrder="29" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="End Date">
          <dataDescriptor expression="end_date"
           descriptiveExpression="END_DATE" order="3" oracleDatatype="date"
           width="9"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_2">
      <select>
      <![CDATA[-- Доплнительные программы
select pkg_rep_utils.to_money_sep(pc.ins_amount) as dop_summ,
       pkg_rep_utils.to_money_sep(pc.fee) as dop_prem,
       '* "'||decode(plo.description,'Дополнительный инвестиционный доход','ИНВЕСТ',
              upper(plo.description))||'"'
         --||decode(plo.appendix_description, null, '', ' ('||upper(plo.appendix_description)||')') 
         as dop_progr,
        decode(upper(plo.description),  
	    'ДОПОЛНИТЕЛЬНЫЙ ИНВЕСТИЦИОННЫЙ ДОХОД', 1,
 	    0) as dop_inv,

--||decode(plo.appendix_description, null, '', ' ('||upper(plo.appendix_description)||')')
            decode(upper(plo.description), 
              'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ДАЛЬНЕЙШИХ ВЗНОСОВ', 1, 
              'ЗАЩИТА СТРАХОВЫХ ВЗНОСОВ', 1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ СТРАХОВЫХ ВЗНОСОВ', 1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ДАЛЬНЕЙШИХ ВЗНОСОВ РАСЧИТАННОЕ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ВЗНОСОВ РАСЧИТАННОЕ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
	'ЗАЩИТА СТРАХОВЫХ ВЗНОСОВ РАСЧИТАННАЯ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
              0) as need_x
from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc, 
        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt,
        ven_t_lob_line tll,
        ven_t_lob tl,
        ven_t_insurance_group ig
where pp.policy_id = :P_POLICY_ID --782299
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief = 'OPTIONAL'
 and pl.t_lob_line_id = tll.t_lob_line_id
 and tl.t_lob_id = tll.t_lob_id
 and ig.t_insurance_group_id = tll.insurance_group_id
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
 and (ig.brief <> 'Acc'
  or (ig.brief = 'Acc' and (plo.id = 22603 or plo.description like 'Освобождение%' or plo.description like 'Защита%'))) -- согласовано с Д.Ивановым! добавлено два последних or Веселуха
]]>
      </select>
	  <group name="G_dop_summ">
      </group>
    </dataSource>
    <dataSource name="Q_uslov">
      <select>
      <![CDATA[
select rownum || '. ' || text as text from
(
  select
  'ДОГОВОР СТРАХОВАНИЯ ЗАКЛЮЧЕН НА ОСНОВАНИИ "ПОЛИСНЫХ УСЛОВИЙ К ПРОГРАММЕ СТРАХОВАНИЯ "СЕМЕЙНЫЙ ДЕПОЗИТ".' text,
  '*' prog
  from dual
  union all
  select
  'СТОРОНЫ ПРИЗНАЮТ РАВНУЮ ЮРИДИЧЕСКУЮ СИЛУ СОБСТВЕННОРУЧНОЙ ПОДПИСИ И ФАКСИМИЛЕ ПОДПИСИ СТРАХОВЩИКА (ВОСПРОИЗВЕДЕННОЕ МЕХАНИЧЕСКИМ ИЛИ ИНЫМ СПОСОБОМ С ИСПОЛЬЗОВАНИЕМ КЛИШЕ) НА ПОЛИСЕ, А ТАКЖЕ ПРИЛОЖЕНИЯХ И ДОПОЛНИТЕЛЬНЫХ СОГЛАШЕНИЯХ К НЕМУ.' text,
  '*' prog
  from dual
--  union all
--  select
--  'В СЛУЧАЕ СМЕРТИ ЗАСТРАХОВАННОГО ЛИЦА ВЫГОДОПРИОБРЕТАТЕЛЯМ ПРОИЗВОДИТСЯ СТРАХОВАЯ ВЫПЛАТА В РАЗМЕРЕ УПЛАЧЕННЫХ ПО ОСНОВНОЙ ПРОГРАММЕ СТРАХОВЫХ ВЗНОСОВ.' text,
--  '*' prog
--  from dual
  union all
  select
  'ТЕРРИТОРИЯ СТРАХОВАНИЯ: ВЕСЬ МИР.' text,
  '*' prog
  from dual
  union all
  select
  'ВРЕМЯ ДЕЙСТВИЯ СТРАХОВОЙ ЗАЩИТЫ: 24 ЧАСА.' text,
  '*' prog
  from dual
  union all
  select
  'ПРИ ДОСРОЧНОМ  РАСТОРЖЕНИИ ДОГОВОРА ВЫПЛАТА ПРЕДУСМОТРЕННОЙ СООТВЕТСТВУЮЩЕЙ ПРОГРАММОЙ СТРАХОВАНИЯ ВЫКУПНОЙ СУММЫ ПРОИЗВОДИТСЯ СОГЛАСНО ТАБЛИЦЕ ВЫКУПНЫХ СУММ  (ПРИЛОЖЕНИЕ № 1).' text,
  '*' prog
  from dual
  union all
  select
  'ДАТА ДОСРОЧНОГО ПРЕКРАЩЕНИЯ ВЫЖИДАТЕЛЬНОГО ПЕРИОДА: ' || :WAITING_PERIOD_END_DATE || '.' text,
  '*' prog
  from dual
  where :PRINT_8_4 = '1'
  union all
  select
  'ЛЬГОТНЫЙ ПЕРИОД: 45 ДНЕЙ.' text,
  '*' prog
  from dual
  union all
  select
  case :CUR_POLICY when 121 then 'РАСЧЕТ СТРАХОВЫХ СУММ И СТРАХОВЫХ ПРЕМИЙ ПРОИЗВЕДЕН С УЧЕТОМ ГАРАНТИРОВАННОЙ НОРМЫ ДОХОДНОСТИ - 3%. ' when 122 then 'РАСЧЕТ СТРАХОВЫХ СУММ И СТРАХОВЫХ ПРЕМИЙ ПРОИЗВЕДЕН С УЧЕТОМ ГАРАНТИРОВАННОЙ НОРМЫ ДОХОДНОСТИ - 4%. ' else 'РАСЧЕТ СТРАХОВЫХ СУММ И СТРАХОВЫХ ПРЕМИЙ ПРОИЗВЕДЕН С УЧЕТОМ ГАРАНТИРОВАННОЙ НОРМЫ ДОХОДНОСТИ - 3%. ' end as text,
  '*' prog
  from dual
 union all
  select
  case :CUR_POLICY when 122 then '' else 'СТРАХОВОЕ ВОЗМЕЩЕНИЕ ВЫПЛАЧИВАЕТСЯ В РУБЛЯХ ПО КУРСУ ЦЕНТРАЛЬНОГО БАНКА РФ, УСТАНОВЛЕННОМУ ДЛЯ ВАЛЮТЫ ДОГОВОРА НА ДАТУ ВЫПЛАТЫ (ПЕРЕЧИСЛЕНИЯ)' end as text,
  '*' prog
  from dual
where :CUR_POLICY <> 122
 ) 
 where prog like '%'||:BRIEF_PRODUCT||'%'
    or prog like '%*%']]>
      </select>
      <displayInfo x="4.19106" y="2.54000" width="1.77788" height="0.50788"/>
      <group name="G_text">
        <displayInfo x="3.68319" y="4.95288" width="2.79394" height="0.65980"
        />
        <dataItem name="text" datatype="vchar2" columnOrder="13" width="340"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Text">
          <dataDescriptor expression="rownum || text"
           descriptiveExpression="TEXT" order="1" width="340"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ns">
      <select>
      <![CDATA[
select 
       pkg_rep_utils.to_money_sep(pc.ins_amount) as dop_summ_ns,
       pkg_rep_utils.to_money_sep(pc.fee) as dop_prem_ns,
--       upper(plo.description) as dop_progr_ns,
--       decode(instr(upper(plo.description), 'ТЕЛЕСНЫЕ ПОВРЕЖДЕНИЯ'), 0, upper(plo.description), upper(plo.description) || ', ПРЕДУСМОТРЕННЫЕ ТАБЛИЦЕЙ СТРАХОВЫХ ВЫПЛАТ ПО РИСКУ "ТЕЛЕСНЫЕ ПОВРЕЖДЕНИЯ В РЕЗУЛЬТАТЕ НЕСЧАСТНОГО СЛУЧАЯ"') as dop_progr_ns
       upper(plo.description) as dop_progr_ns
from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc, 
        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt,
        ven_t_lob_line tll,
        ven_t_lob tl,
        ven_t_insurance_group ig
where pp.policy_id = :P_POLICY_ID --782299
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief = 'OPTIONAL'
 and pl.t_lob_line_id = tll.t_lob_line_id
 and tl.t_lob_id = tll.t_lob_id
 and ig.t_insurance_group_id = tll.insurance_group_id
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
 and ig.brief = 'Acc'
 and plo.id not in (22603,32005,44179,22629,27622,27624,28063,28065,28336,32005,43607,43609,44103,44131,44177,57134,57138,57738,57802,57871,57925,58264) -- согласовано с Д.Ивановым! добавлено 32005 Веселуха
]]>
      </select>
      <group name="G_dop_summ_ns">
      </group>
    </dataSource>
    <dataSource name="Q_3">
      <select>
      <![CDATA[select 
nvl(ent.obj_name('CONTACT',b.contact_id),'X') as beneficiary,
nvl(to_char(pkg_contact.get_birth_date(b.contact_id),'dd.mm.yyyy'),'X') as ben_birth,
nvl(pkg_contact.get_rel_description(su.assured_contact_id,b.contact_id),'X') as ben_rel,
decode(b.value,null,'X',pkg_rep_utils.to_money_sep(b.value) || ' ' || decode(pth.brief,'percent','%','absol',f.brief)) as ben_part
from 
ven_as_asset a,
ven_as_assured su , 
ven_as_beneficiary b,
t_path_type   pth,
fund f,
(select :P_POLICY_ID id from dual) dd
where a.p_policy_id(+) = dd.id
 and b.as_asset_id(+) = a.as_asset_id
 and su.as_assured_id(+) = a.as_asset_id
 and pth.t_path_type_id (+) = b.value_type_id
 and f.fund_id (+) = b.t_currency_id]]>
      </select>
      <displayInfo x="10.21271" y="2.93688" width="1.77788" height="0.50788"/>
      <group name="G_beneficiary">
        <displayInfo x="9.56128" y="4.71475" width="3.08105" height="2.39613"
        />
        <dataItem name="beneficiary" datatype="vchar2" columnOrder="33"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Beneficiary">
          <dataDescriptor
           expression="nvl ( ent.obj_name ( &apos;CONTACT&apos; , b.contact_id ) , &apos;X&apos; )"
           descriptiveExpression="BENEFICIARY" order="1" width="4000"/>
        </dataItem>
        <dataItem name="ben_birth" datatype="vchar2" columnOrder="34"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ben Birth">
          <dataDescriptor
           expression="nvl ( to_char ( pkg_contact.get_birth_date ( b.contact_id ) , &apos;dd.mm.yyyy&apos; ) , &apos;X&apos; )"
           descriptiveExpression="BEN_BIRTH" order="2" width="10"/>
        </dataItem>
        <dataItem name="ben_rel" datatype="vchar2" columnOrder="35"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ben Rel">
          <dataDescriptor
           expression="nvl ( pkg_contact.get_rel_description ( su.assured_contact_id , b.contact_id ) , &apos;X&apos; )"
           descriptiveExpression="BEN_REL" order="3" width="4000"/>
        </dataItem>
        <dataItem name="ben_part" datatype="vchar2" columnOrder="36"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ben Part">
          <dataDescriptor
           expression="decode ( b.value , null , &apos;X&apos; , pkg_rep_utils.to_money_sep ( b.value ) || &apos; &apos; || decode ( pth.brief , &apos;percent&apos; , &apos;%&apos; , &apos;absol&apos; , f.brief ) )"
           descriptiveExpression="BEN_PART" order="4" width="4000"/>
        </dataItem>
      </group>
    </dataSource>

    <dataSource name="Q_4">
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
  and p.policy_id= :P_POLICY_ID
  and p.T_LOB_LINE_ID = (select distinct T_LOB_LINE_ID from ven_t_product_line prl, ven_t_product_line_type prt
  where  prl.product_line_type_id = prt.product_line_type_id
  and p.T_LOB_LINE_ID = prl.T_LOB_LINE_ID
  and prl.visible_flag = 1
  and prt.brief = 'RECOMMENDED')
    order by d.start_cash_surr_date  ) v where rownum <= 47]]>
      </select>
      <displayInfo x="14.94358" y="3.99510" width="2.75177" height="0.50788"/>
      <group name="G_INSURANCE_YEAR_NUMBER">
        <displayInfo x="13.62832" y="5.63997" width="5.38293" height="2.83021"
        />
        <dataItem name="PERIOD_START" datatype="vchar2" columnOrder="45"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period Start">
          <dataDescriptor expression="PERIOD_START"
           descriptiveExpression="PERIOD_START" order="3" width="10"/>
        </dataItem>
        <dataItem name="PERIOD_END" datatype="vchar2" columnOrder="46"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period End">
          <dataDescriptor expression="PERIOD_END"
           descriptiveExpression="PERIOD_END" order="4" width="10"/>
        </dataItem>
        <dataItem name="YEAR_NUMBER" oracleDatatype="number" columnOrder="43"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Year Number">
          <dataDescriptor expression="YEAR_NUMBER"
           descriptiveExpression="YEAR_NUMBER" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="RANSOM" datatype="vchar2" columnOrder="44"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ransom">
          <dataDescriptor expression="RANSOM" descriptiveExpression="RANSOM"
           order="5" width="4000"/>
        </dataItem>
        <dataItem name="N" oracleDatatype="number" columnOrder="42" width="22"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="N">
          <dataDescriptor expression="N" descriptiveExpression="N" order="1"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>



<dataSource name="Q_6">
      <select canParse="no">
      <![CDATA[select *
from (select 
rownum as n, 
v.insurance_year_number as year_number,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end,
pkg_rep_utils.to_money_sep(v.value) as ransom
from
 (select d.* from ven_policy_cash_surr p, ven_policy_cash_surr_d d
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :P_POLICY_ID
  and p.T_LOB_LINE_ID = (select distinct T_LOB_LINE_ID from ven_t_product_line prl, ven_t_product_line_type prt
  where  prl.product_line_type_id = prt.product_line_type_id
  and p.T_LOB_LINE_ID = prl.T_LOB_LINE_ID
  and prl.visible_flag = 1
  and prt.brief = 'RECOMMENDED')
    order by d.start_cash_surr_date  ) v ) where n > 47]]>
      </select>
      <displayInfo x="14.94358" y="3.99510" width="2.75177" height="0.50788"/>
      <group name="G_INSURANCE_YEAR_NUMBER_d">
        <displayInfo x="13.62832" y="5.63997" width="5.38293" height="2.83021"
        />
        <dataItem name="PERIOD_START_d" datatype="vchar2" columnOrder="45"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period Start d">
          <dataDescriptor expression="PERIOD_START_d"
           descriptiveExpression="PERIOD_START_d" order="3" width="10"/>
        </dataItem>
        <dataItem name="PERIOD_END_d" datatype="vchar2" columnOrder="46"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period End d">
          <dataDescriptor expression="PERIOD_END_d"
           descriptiveExpression="PERIOD_END_d" order="4" width="10"/>
        </dataItem>
        <dataItem name="YEAR_NUMBER_d" oracleDatatype="number" columnOrder="43"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Year Number d">
          <dataDescriptor expression="YEAR_NUMBER_d"
           descriptiveExpression="YEAR_NUMBER_d" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="RANSOM_d" datatype="vchar2" columnOrder="44"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ransom d">
          <dataDescriptor expression="RANSOM_d" descriptiveExpression="RANSOM d"
           order="5" width="4000"/>
        </dataItem>
        <dataItem name="N_d" oracleDatatype="number" columnOrder="42" width="22"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="N d">
          <dataDescriptor expression="N_d" descriptiveExpression="N_d" order="1"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>




	<dataSource name="Q_5">
      <select canParse="no">
      <![CDATA[select 
rownum as n_i,
v.insurance_year_number as year_number_i,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start_i,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end_i,
pkg_rep_utils.to_money_sep(v.value) as ransom_i
from
 (select d.* from ven_policy_cash_surr p, ven_policy_cash_surr_d d
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :P_POLICY_ID
  and p.T_LOB_LINE_ID = (select distinct T_LOB_LINE_ID from ven_t_product_line prl, ven_t_product_line_type prt
  where  prl.product_line_type_id = prt.product_line_type_id
  and p.T_LOB_LINE_ID = prl.T_LOB_LINE_ID
  and prl.visible_flag = 1
  and prt.brief = 'OPTIONAL')
    order by d.start_cash_surr_date  ) v]]>
      </select>
      <displayInfo x="14.94358" y="3.99510" width="2.75177" height="0.50788"/>
      <group name="G_INSURANCE_YEAR_NUMBER_I">
        <displayInfo x="13.62832" y="5.63997" width="5.38293" height="2.83021"
        />
        <dataItem name="PERIOD_START_I" datatype="vchar2" columnOrder="45"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period Start I">
          <dataDescriptor expression="PERIOD_START_I"
           descriptiveExpression="PERIOD_START_I" order="3" width="10"/>
        </dataItem>
        <dataItem name="PERIOD_END_I" datatype="vchar2" columnOrder="46"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period End I">
          <dataDescriptor expression="PERIOD_END_I"
           descriptiveExpression="PERIOD_END_I" order="4" width="10"/>
        </dataItem>
        <dataItem name="YEAR_NUMBER_I" oracleDatatype="number" columnOrder="43"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Year Number I">
          <dataDescriptor expression="YEAR_NUMBER_I"
           descriptiveExpression="YEAR_NUMBER_I" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="RANSOM_I" datatype="vchar2" columnOrder="44"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ransom I">
          <dataDescriptor expression="RANSOM_I" descriptiveExpression="RANSOM_I"
           order="5" width="4000"/>
        </dataItem>
        <dataItem name="N_I" oracleDatatype="number" columnOrder="42" width="22"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="N I">
          <dataDescriptor expression="N_I" descriptiveExpression="N_I" order="1"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>

  </data>
  <parameterForm width="27.53350" height="27.53350"/>
  <programUnits>
    <function name="afterpform">
      <textSource>
      <![CDATA[function AfterPForm return boolean is
buf varchar2(1500);
begin
:P_OSN_PROGR := 0;

for rec in (select decode(rownum,1,t.description,', ' || t.description) val  
           from (select '"' || plo.description || '"' as description from 
                ven_p_policy pp, 
                ven_as_asset ass, 
                ven_p_cover pc, 
                ven_t_prod_line_option plo,
                ven_t_product_line pl,
                ven_t_product_line_type plt
            where pp.policy_id = :P_POLICY_ID
             and ass.p_policy_id = pp.policy_id
             and pc.as_asset_id = ass.as_asset_id
             and plo.id = pc.t_prod_line_option_id
             and plo.product_line_id = pl.id
             and pl.product_line_type_id = plt.product_line_type_id
             and plt.brief = 'OPTIONAL'
             and (trunc(pc.end_date) - trunc(pc.start_date)) between 365 and 366
             and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
             order by plo.description) t ) 
    LOOP
        buf:= buf || rec.val;
    END LOOP;
    buf := '(' || rtrim(buf,';') || ')';
  :P_DOP_PROGR := '';



    -- Страховщик

  begin
   select v.COMPANY_TYPE || ' ' || v.COMPANY_NAME || ', ' || v.LEGAL_ADDRESS,
     'ИНН '||v.INN || ', КПП ' || v.KPP || ', P/C ' || v.ACCOUNT_NUMBER || 
     ' В ' || v.BANK_COMPANY_TYPE || ' "' || v.BANK_NAME ||'", г.Москва '||decode(nvl(v.B_BIC,' '),' ','',', БИК ' || v.B_BIC) ||
     decode(nvl(v.B_KOR_ACCOUNT,' '),' ','',', К/С  ' || v.B_KOR_ACCOUNT)
   into :INSURER,:INSURER_INN
   from v_company_info v;
  exception
      when no_data_found then :INSURER := ''; :INSURER_INN := ''; 
  end;
  
begin
select 
   nvl(ent.obj_name(con_a.ent_id,con_a.contact_id),' ') ag_fio,
   nvl(ah.NUM,' ') tn
   into :PA_CURATOR, :PA_TABNUM  
   from ven_p_pol_header ph, ven_p_policy pp, ven_p_policy_agent pa, ven_ag_contract_header ah ,ven_contact con_a, ven_employee ve
   where pp.pol_header_id=ph.policy_header_id 
     and pp.policy_id = :P_POLICY_ID
     and ph.policy_header_id=pa.policy_header_id
     and ah.ag_contract_header_id = pa.ag_contract_header_id
     and con_a.contact_id = ah.agent_id
     and con_a.CONTACT_ID = ve.CONTACT_ID(+)
     and pa.status_id not in (2,4)
     and rownum = 1;
exception
    when no_data_found then :PA_CURATOR := ' '; :PA_TABNUM := ' ';   
  end;   
  
  
  -- Номер полиса, 2.Страхователь, 3. Застрахованное лицо     
   begin
  select  
       -- Полис
    ak.brief,
    decode(pp.pol_ser,null,pp.pol_num,pp.pol_ser || '-' || pp.pol_num),
    pp.notice_ser||pp.notice_num,
    ph.fund_id,
       -- Продукт
    upper(ent.obj_name('T_PRODUCT',ph.product_id)),
    to_char(sysdate,'dd.mm.yyyy'),
    -- Страхователь
   cont.contact_type_id,
   case when cont.contact_type_id not in (1,3,1030) then comp.addr else ent.obj_name('CONTACT', pkg_policy.get_policy_holder_id(pp.policy_id)) end,
   case when cont.contact_type_id not in (1,3,1030) then '' else to_char(pkg_contact.get_birth_date(pkg_policy.get_policy_holder_id(pp.policy_id)),
         'dd.mm.yyyy') end,
   case when cont.contact_type_id not in (1,3,1030) then comp.dd else replace(replace(pkg_contact.get_primary_doc(pkg_policy.get_policy_holder_id(pp.policy_id)),
                 'Паспорт гражданина РФ  Номер',
                 'Паспорт'),
         '-',
         ' ') end,
        -- Застрахованный
    ent.obj_name('CONTACT',s.assured_contact_id),
    to_char(pkg_contact.get_birth_date(s.assured_contact_id),'dd.mm.yyyy'),
    replace(replace(pkg_contact.get_primary_doc (s.assured_contact_id),
            'Паспорт гражданина РФ  Номер','Паспорт'),'-',' '),
    lower(vt.DESCRIPTION),
    nvl(to_char(ds.start_date,'dd.mm.yyyy'),' '),
    nvl(rcnt.row_cnt,0) row_cnt,
     decode(vf.brief, 
           'RUR', 'руб.', 
           'USD', 'дол.',
           'EUR', 'евро.',
           vf.brief) kod_val,
decode(vf.brief, 
           'RUR', 'РУБ.', 
           'USD', 'ДОЛ.',
           'EUR', 'ЕВРО',
           vf.brief) kod_val_up
    into :BRIEF_PRODUCT,:POL_NUM,:P_NOTICE,:CUR_POLICY,:PROGRAMMA,:P_SYSDATE,:TYPE_CONT,:POL_HOLDER,:PH_BIRTH,:PH_DOC,:POL_ASS,:PA_BIRTH,:PA_DOC, :PA_PERIODICH, :WAITING_PERIOD_END_DATE, :PA_ROW_PRIL, :PA_KOD_VAL,:PA_KOD_VAL_UP
    from t_product ak, ven_p_policy pp, ven_p_pol_header ph, ven_as_asset a , ven_as_assured s, contact cont, VEN_T_PAYMENT_TERMS vt, VEN_FUND vf,
    (select p.policy_id, count(1) row_cnt 
   from ven_policy_cash_surr p, ven_policy_cash_surr_d d 
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :P_POLICY_ID group by p.policy_id) rcnt,
  ( select document_id, start_date from (
    select ds.document_id, ds.start_date from ven_doc_status ds, ven_doc_status_ref dsr 
    where ds.doc_status_ref_id = dsr.doc_status_ref_id(+)
      and dsr.brief = 'ACTIVE' and ds.document_id = :P_POLICY_ID order by ds.start_date desc ) where rownum = 1) ds,
v_temp_company comp
    where pp.policy_id = :P_POLICY_ID
     and s.contact_id = cont.contact_id
     and cont.contact_id = comp.contact_id
     and ph.policy_header_id = pp.pol_header_id
     and a.p_policy_id = pp.policy_id
     and ak.product_id = ph.product_id
     and pp.policy_id = ds.document_id(+) 
     and pp.policy_id = rcnt.policy_id(+)
     and ph.FUND_ID = vf.FUND_ID(+)     
     and s.as_assured_id = a.as_asset_id
     and pp.PAYMENT_TERM_ID = vt.ID(+);
  exception
    when no_data_found then :WAITING_PERIOD_END_DATE := ' ';
    
  end;


 declare
    v_datediff number;
    v_print_date date;
  begin

select trunc(pc.start_date), trunc(sysdate) - trunc(pc.start_date)
into v_print_date, v_datediff
from    ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc,

        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt
        
where pp.policy_id = :P_POLICY_ID
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id

      and plo.id = pc.t_prod_line_option_id
      and plo.product_line_id = pl.id
      and pl.product_line_type_id = plt.product_line_type_id
      and plt.brief = 'RECOMMENDED';

   if (v_datediff > 60) then
      v_print_date := v_print_date + 61;
      :PRINT_8_4 := '0';
   else
      v_print_date := to_date(:WAITING_PERIOD_END_DATE, 'DD.MM.YYYY');
      :PRINT_8_4 := '1';
   end if;

   :PRINT_DATE_CHAR := to_char(v_print_date, 'DD.MM.YYYY');
  
  exception
    when others then :PRINT_DATE_CHAR := to_char(sysdate, 'DD.MM.YYYY');
  
  end;


 

-- 4. Программы страхования 
   -- Основная программа
  
 begin
    select pkg_rep_utils.to_money_sep(pc.ins_amount),
       pkg_rep_utils.to_money_sep(pc.fee),
       '"'||('СМЕРТЬ ЗАСТРАХОВАННОГО ПО ЛЮБОЙ ПРИЧИНЕ, '||'          '||'ДОЖИТИЕ ЗАСТРАХОВАННОГО ДО ДАТЫ ОКОНЧАНИЯ СРОКА ДЕЙСТВИЯ ДОГОВОРА')||'"'
    into :MAIN_COVER_SUM, :MAIN_COVER_PREM, :MAIN_COVER
    from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc, 
        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt
    where pp.policy_id = :P_POLICY_ID
     and ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
     and plo.product_line_id = pl.id
     and pl.product_line_type_id = plt.product_line_type_id
     and plt.brief = 'RECOMMENDED'
     and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
     and rownum = 1;


   -- Итого
     -- Итоговая премия (По основной и доп программам - кроме Адм. издержек)
 select pkg_rep_utils.to_money_sep(sum(pc.fee))
  into :ITOGO_PREM
  from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc, 
        ven_t_prod_line_option plo
  where pp.policy_id = :P_POLICY_ID
   and ass.p_policy_id = pp.policy_id
   and pc.as_asset_id = ass.as_asset_id
   and plo.id = pc.t_prod_line_option_id
   and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ';
exception 
     when no_data_found then :MAIN_COVER:='ОШИБКА! Отсутствует основная программа';
  end;
-- АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ
 
 begin
    select pkg_rep_utils.to_money_sep(pc.fee)
      into :ADMIN_PAY -- Административные издержки
    from 
            ven_p_policy pp, 
            ven_as_asset ass, 
            ven_p_cover pc, 
            ven_t_prod_line_option plo
    where pp.policy_id = :P_POLICY_ID
     and ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
     and upper(trim(plo.description)) = 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
     and rownum = 1;
  exception
    when no_data_found then :ADMIN_PAY := '0,00';    
  end;
 


-- 6. Условия и сроки уплаты страховой премии
-- Дата уплаты первого последующих взносов
    begin
    select 
    to_char(pps.due_date,'dd.mm.yyyy'),
    decode(nvl(pt.number_of_payments,0),0,'X',1,to_char(pps.due_date,'dd.mm'),
                      2,to_char(add_months(pps.due_date,6),'dd.mm') || ', ' ||to_char(pps.due_date,'dd.mm'),
                                        4,to_char(add_months(pps.due_date,3),'dd.mm') || ', ' ||to_char(add_months(pps.due_date,6),'dd.mm') || ', ' ||
                                        to_char(add_months(pps.due_date,9),'dd.mm') || ', ' ||to_char(pps.due_date,'dd.mm'))
    into :FIRST_PAY, :NEXT_PAYS
    from v_policy_payment_schedule pps, ven_ac_payment ap, ven_p_policy pp, ven_t_payment_terms pt
    where pps.pol_header_id = pp.pol_header_id 
    and pps.document_id = ap.payment_id
  	and pp.policy_id = :P_POLICY_ID
  	and pp.payment_term_id = pt.id
	  and ap.payment_number = 1;
  exception
    when no_data_found then :NEXT_PAYS := 'X';    
  end;

-- Программа и  Текущая дата.
begin   
    SELECT count(*) into :P_CNT_POVREZH       
  FROM p_cover pc, t_prod_line_option pro, ven_as_asset vass
 WHERE pc.t_prod_line_option_id = pro.ID(+)
   and vass.p_policy_id = :P_POLICY_ID
   and vass.as_asset_id = pc.AS_ASSET_ID  
   and upper(pro.description) like '%ТЕЛЕСНЫЕ ПОВРЕЖДЕНИЯ ЗАСТРАХОВАННОГО%';
  exception
      when no_data_found then :P_CNT_POVREZH := 0; 
  end;

-- Доплнительные программы

begin
select count(*) into :P_EXIST_DOP
from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc, 
        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt
where pp.policy_id = :P_POLICY_ID 
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief = 'OPTIONAL'
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ';
  exception
      when no_data_found then :P_EXIST_DOP := 0; 
  end;


begin
select count(*) into :P_EXIST_AVTOPR
from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc
where pp.policy_id = :P_POLICY_ID
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and pc.is_avtoprolongation = 1;
exception
      when no_data_found then :P_EXIST_AVTOPR := 0; 
end;


-- Доплнительные программы
begin

select count(*) into :P_EXIST_DOP_NS
from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc, 
        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt,
        ven_t_lob_line tll,
        ven_t_lob tl,
        ven_t_insurance_group ig
where pp.policy_id = :P_POLICY_ID --782299
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief = 'OPTIONAL'
 and pl.t_lob_line_id = tll.t_lob_line_id
 and tl.t_lob_id = tll.t_lob_id
 and ig.t_insurance_group_id = tll.insurance_group_id
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
 and ig.brief = 'Acc'
 and plo.id not in (22603,32005,44179,22629,27622,27624,28063,28065,28336,32005,43607,43609,44103,44131,44177,57134,57138,57738,57802,57871,57925,58264) -- согласовано с Д.Ивановым! добавлено 32005 Веселуха
;
  exception
      when no_data_found then :P_EXIST_DOP_NS := 0; 
  end;


  if (:P_CNT_POVREZH > 0) then
    :P_TEL_VRED := '1';
  else
    :P_TEL_VRED := '0';
  end if;   

  return (TRUE);

   end;]]>
      </textSource>
    </function>
    <function name="cf_srokformula" returnType="character">
      <textSource>
      <![CDATA[function CF_SROKFormula return Char is
-- Функция финамически строит перечень рисков для 5. Период страхования
buf varchar2(500);
begin
  
  if (:P_OSN_PROGR > 0) then begin
  
-- Выбираем все доп программы относящиеся, к данному сроку страхования  
for rec in (select decode(rownum,1,'дополнительные страховые риски' ||' ',' ') val  
           from (select '"' || decode(plo.description,'Дополнительный инвестиционный доход','Инвест',
              (plo.description)) || '"' as description from 
                ven_p_policy pp, 
                ven_as_asset ass, 
                ven_p_cover pc, 
                ven_t_prod_line_option plo,
                ven_t_product_line pl,
                ven_t_product_line_type plt
            where pp.policy_id = :P_POLICY_ID
             and ass.p_policy_id = pp.policy_id
             and pc.as_asset_id = ass.as_asset_id
             and plo.id = pc.t_prod_line_option_id
             and plo.product_line_id = pl.id
             and pl.product_line_type_id = plt.product_line_type_id
             and plt.brief = 'OPTIONAL'
             and trunc(pc.start_date) = trunc(:start_date)
             and trunc(pc.end_date) = trunc(:end_date)
             and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
             order by plo.description) t ) 
    LOOP
        buf:= buf || rec.val;
    END LOOP;
    buf := '(' || rtrim(buf,';') || ')';
  end; else begin 
    :P_OSN_PROGR := 1;
      -- Проверяем входит ли в срок страхования Основная программа
    select '(основные страховые риски)'
    into buf 
    from 
      ven_p_policy pp, 
      ven_as_asset ass, 
      ven_p_cover pc, 
      ven_t_prod_line_option plo,
      ven_t_product_line pl,
      ven_t_product_line_type plt
    where pp.policy_id = :P_POLICY_ID
      and ass.p_policy_id = pp.policy_id
      and pc.as_asset_id = ass.as_asset_id
      and plo.id = pc.t_prod_line_option_id
      and plo.product_line_id = pl.id
      and pl.product_line_type_id = plt.product_line_type_id
      and plt.brief = 'RECOMMENDED'
      and trunc(pc.start_date) = trunc(:start_date)
      and trunc(pc.end_date) = trunc(:end_date);
  exception
    when no_data_found then buf := null;      
  end;
    
  end if;
    return (buf);
end;]]>
      </textSource>
    </function>
    <function name="cf_end_dateformula" returnType="character">
      <textSource>
      <![CDATA[function CF_end_dateFormula return Char is
 n number;
 d date := :end_date;
 buf varchar2(6);
begin
 n:=to_number(to_char(d,'hh24'));
 if n in (1,21) then 
   buf := 'час ';
 else if n in (2,3,4,22,23,23) then 
        buf := 'часа ';
      else buf := 'часов ';
      end if;
  end if;
 return('00:00' || ' ' || 'часов ' || to_char(d,'dd.mm.yyyy'));
end;]]>
      </textSource>
    </function>
    <function name="cf_start_dateformula" returnType="character">
      <textSource>
      <![CDATA[function CF_start_dateFormula return Char is
 n number;
 d date := :start_date;
 buf varchar2(6);
begin
 n:=to_number(to_char(d,'hh24'));
 if n in (1,21) then 
   buf := 'час ';
 else if n in (2,3,4,22,23,23) then 
        buf := 'часа ';
      else buf := 'часов ';
      end if;
  end if;
 return(to_char(d,'hh24:mi') || ' ' || buf || ' ' || to_char(d,'dd.mm.yyyy'));
end;]]>
      </textSource>
    </function>
    <function name="cf_yearformula" returnType="character">
      <textSource>
      <![CDATA[function CF_yearFormula return Char is
buf varchar2(20);
n number;
begin
    n := MOD(:years,10);
    if (:years >10) and (:years<20) 
        then return to_char(:years) || ' лет';
    else if n = 1 then return to_char(:years) || ' год';
         else if (n = 3) or (n = 4) then return to_char(:years) || ' года';
              else return to_char(:years) || ' лет';
              end if;
         end if;
    end if;
return ' ';
end;]]>
      </textSource>
    </function>
  </programUnits>
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
<title>Полис № <rw:field id="" src="POL_NUM"/></title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>korendm</o:Author>
  <o:Template>policy_blank_06.dot</o:Template>
  <o:LastAuthor>Vitaly Ustinov</o:LastAuthor>
  <o:Revision>9</o:Revision>
  <o:TotalTime>5</o:TotalTime>
  <o:LastPrinted>2007-07-31T06:07:00Z</o:LastPrinted>
  <o:Created>2007-10-06T12:36:00Z</o:Created>
  <o:LastSaved>2007-10-06T12:40:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>793</o:Words>
  <o:Characters>4523</o:Characters>
  <o:Company>Renaissance Insurance Group</o:Company>
  <o:Lines>37</o:Lines>
  <o:Paragraphs>10</o:Paragraphs>
  <o:CharactersWithSpaces>5306</o:CharactersWithSpaces>
  <o:Version>11.8122</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:View>Print</w:View>
  <w:ValidateAgainstSchemas/>
  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
  <w:Compatibility>
   <w:SelectEntireFieldWithStartOrEnd/>
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
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
    {mso-style-parent:"";
    margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    font-size:12.0pt;
    font-family:"Times New Roman";
    mso-fareast-font-family:"Times New Roman";
    mso-ansi-language:EN-US;
    mso-fareast-language:EN-US;}
h1
    {mso-style-next:Обычный;
    margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    page-break-after:avoid;
    mso-outline-level:1;
    font-size:8.0pt;
    font-family:"Times New Roman";
    mso-font-kerning:0pt;
    mso-bidi-font-weight:normal;}
h2
    {mso-style-next:Обычный;
    margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    page-break-after:avoid;
    mso-outline-level:2;
    font-size:10.0pt;
    font-family:"Times New Roman";
    mso-bidi-font-weight:normal;}
p.MsoHeader, li.MsoHeader, div.MsoHeader
    {margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    tab-stops:center 233.85pt right 467.75pt;
    font-size:12.0pt;
    font-family:"Times New Roman";
    mso-fareast-font-family:"Times New Roman";
    mso-ansi-language:EN-US;
    mso-fareast-language:EN-US;}
p.MsoFooter, li.MsoFooter, div.MsoFooter
    {margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    tab-stops:center 233.85pt right 467.75pt;
    font-size:12.0pt;
    font-family:"Times New Roman";
    mso-fareast-font-family:"Times New Roman";
    mso-ansi-language:EN-US;
    mso-fareast-language:EN-US;}
span.Items
    {mso-style-name:Items;
    font-weight:bold;
    mso-bidi-font-weight:normal;}
 /* Page Definitions */
@page Section1
    {size:595.3pt 841.9pt;
    margin:70.9pt 2.0cm 45.1pt 3.0cm;
    mso-header-margin:35.45pt;
    mso-footer-margin:14.2pt;
    mso-paper-source:0;}
div.Section1
    {page:Section1;}
@page Section2
    {size:595.3pt 841.9pt;
    margin:70.9pt 2.0cm 152.8pt 3.0cm;
    mso-header-margin:35.45pt;
    mso-footer-margin:14.2pt;
    mso-paper-source:0;}
div.Section2
    {page:Section2;}
@page Section3
    {size:595.3pt 841.9pt;
    margin:70.9pt 2.0cm 152.8pt 3.0cm;
    mso-header-margin:35.45pt;
    mso-footer-margin:14.2pt;
    mso-paper-source:0;}
div.Section3
    {page:Section3;}
 /* List Definitions */
 @list l0
    {mso-list-id:1868448227;
    mso-list-type:hybrid;
    mso-list-template-ids:-1196758838 67698703 67698713 67698715 67698703 67698713 67698715 67698703 67698713 67698715;}
@list l0:level1
    {mso-level-tab-stop:36.0pt;
    mso-level-number-position:left;
    text-indent:-18.0pt;}
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
    {mso-style-name:"Обычная таблица";
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
<![endif]--><!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="2050"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>


<rw:getValue id="jProdBrief" src="BRIEF_PRODUCT"/>



<body lang=RU style='tab-interval:36.0pt'>

<div class=Section1>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=708
 style='width:531.0pt;mar-gin-left:-48.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='margin-top:32.0pt;margin-right:0cm;
  margin-bottom:12.0pt;margin-left:0cm;text-align:center'><b><span
  style='font-size:20.0pt;mso-bidi-font-size:12.0pt;color:#FF6600;mso-ansi-language:
  RU'><rw:field id="" src="PROGRAMMA"/></span></b><b><span style='font-size:18.0pt;color:#FF6600;
  mso-ansi-language:RU'> </span></b><b><span lang=EN-US style='font-size:18.0pt;
  color:#FF6600'><o:p></o:p></span></b></p>

  <p class=MsoNormal align=center style='margin-top:12.0pt;margin-right:0cm;
  margin-bottom:12.0pt;margin-left:0cm;text-align:center'><b><span
  style='font-size:18.0pt;color:#FF6600;mso-ansi-language:RU'>Полис страхования жизни № <rw:field id="" src="POL_NUM"/></span></b></p>
  <p class=MsoNormal align=center style='margin-top:12.0pt;margin-right:0cm;
  margin-bottom:12.0pt;margin-left:0cm;text-align:center'><span
  style='font-size:4.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600;mso-ansi-language:RU'>1. СТРАХОВЩИК</span></b><span
  style='font-size:9.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:10.0pt;mso-bidi-font-size:8.0pt;
  mso-ansi-language:RU'><rw:field id="" src="INSURER"/></span></b></p>
  <p class=MsoNormal style='margin-top:6.0pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:8.0pt;mso-ansi-language:RU'></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0.5cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt;
  mso-bidi-font-size:8.0pt;mso-ansi-language:RU'>
  <rw:field id="" src="INSURER_INN"/></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600;mso-ansi-language:RU'>2. СТРАХОВАТЕЛЬ</span></b><span
  style='font-size:9.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
 </tr>

 
 <tr style='mso-yfti-irow:6;height:4.0pt'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
<table> 
 
<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=708
 style='width:531.0pt;mar-gin-left:-48.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;'>

<rw:getValue id="t_cont" src="TYPE_CONT"/>

 <tr style='mso-yfti-irow:7;height:12.75pt'><!-- @@@ -->
  
  <td width=144 valign=top style='width:108.0pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><% if ((t_cont.equals("1")) || (t_cont.equals("3")) || (t_cont.equals("1030"))) { %>Ф.И.О.<% } else { %>НАИМЕНОВАНИЕ ОРГАНИЗАЦИИ<% } %><o:p></o:p></span></b></p>
  </td>
  
  <td width=564 colspan=4 valign=top style='width:423.0pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <h2><rw:field id="" src="POL_HOLDER"/></h2>
  </td>

 </tr>

 
 <tr style='mso-yfti-irow:8'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:9'>
  <td width=144 valign=top style='width:108.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><% if ((t_cont.equals("1")) || (t_cont.equals("3")) || (t_cont.equals("1030"))) { %>ДАТА РОЖДЕНИЯ<% } else { %><% } %><o:p></o:p></span></b></p>
  </td>
  <td width=564 colspan=4 valign=top style='width:423.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'>
  <rw:field id="" src="PH_BIRTH"/><b
  style='mso-bidi-font-weight:normal'><o:p></o:p></b></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:10;height:4.0pt'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:3.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:11'>
  <td width=144 valign=top style='width:108.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><% if ((t_cont.equals("1")) || (t_cont.equals("3")) || (t_cont.equals("1030"))) { %>ДОКУМЕНТ<% } else { %>РЕКВИЗИТЫ ОРГАНИЗАЦИИ<% } %><o:p></o:p></span></b></p>
  </td>
  <td width=564 colspan=4 valign=top style='width:423.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'>
  <rw:field id="" src="PH_DOC"/></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:12'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>

 <tr style='mso-yfti-irow:13'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600;mso-ansi-language:RU'>3. ЗАСТРАХОВАННОЕ ЛИЦО</span></b><span
  style='font-size:9.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:14;height:4.0pt'>
  <td width=144 valign=top style='width:108.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=564 colspan=4 valign=top style='width:423.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:3.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:15'>
  <td width=144 valign=top style='width:108.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>Ф.И.О.<o:p></o:p></span></b></p>
  </td>
  <td width=564 colspan=4 valign=top style='width:423.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt;mso-ansi-language:RU'>
  <rw:field id="" src="POL_ASS"/><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:16'>
  <td width=144 valign=top style='width:108.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=564 colspan=4 valign=top style='width:423.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:3.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:17'>
  <td width=144 valign=top style='width:108.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>ДАТА РОЖДЕНИЯ<o:p></o:p></span></b></p>
  </td>
  <td width=564 colspan=4 valign=top style='width:423.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'>
  <rw:field id="" src="PA_BIRTH"/><b
  style='mso-bidi-font-weight:normal'><o:p></o:p></b></span></p>
  </td>
 </tr>

 <tr style='mso-yfti-irow:18'>
  <td width=144 valign=top style='width:108.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=564 colspan=4 valign=top style='width:423.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:3.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>

<tr style='mso-yfti-irow:19'>
  <td width=144 valign=top style='width:108.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>ДОКУМЕНТ<o:p></o:p></span></b></p>
  </td>
  <td width=564 colspan=4 valign=top style='width:423.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'>
  <rw:field id="" src="PA_DOC"/></span></p>
  </td>
 </tr>

 
</table>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=708
 style='width:531.0pt;mar-gin-left:-48.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;'>
 
 <tr style='mso-yfti-irow:20;height:4.0pt'>
  <td width=144 valign=top style='width:108.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><u><span style='font-size:3.0pt;
  mso-ansi-language:RU'><o:p><span style='text-decoration:none'>&nbsp;</span></o:p></span></u></b></p>
  </td>
  <td width=564 colspan=4 valign=top style='width:423.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>

 <tr style='mso-yfti-irow:21'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600;mso-ansi-language:RU'>4. ПРОГРАММЫ СТРАХОВАНИЯ</span></b><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:22;height:4.0pt'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:3.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:3.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></i></p>
  </td>
 </tr>
 
 
</table>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=708
 style='width:531.0pt;mar-gin-left:-48.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;'>

 <tr style='mso-yfti-irow:23;height:4.0pt'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:3.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt;border:dashed windowtext 1.0pt;'>
  <p class=MsoNormal align=center style='text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'>Страховая сумма,<br><rw:field id="" src="PA_KOD_VAL"/></span></i></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt;border:dashed windowtext 1.0pt;'>
  <p class=MsoNormal align=center style='text-align:center;'><i
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'>Страховая премия, <rw:field id="" src="PA_KOD_VAL"/></span></i></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:24'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:3.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;border:none;
  border-bottom:dashed windowtext 1.0pt;mso-border-bottom-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:25'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>4.1 ОСНОВНЫЕ СТРАХОВЫЕ РИСКИ: </span></b><span
  style='font-size:8.0pt;mso-ansi-language:RU;mso-bidi-font-weight:bold'>
  <rw:field id="" src="MAIN_COVER"/><!--rw:getValue id="j_programma" src="programma"/>
  < % if (j_programma.equals("ГАРМОНИЯ ЖИЗНИ")) { % > (ПУНКТ 3.1. ОБЩИХ УСЛОВИЙ СТРАХОВАНИЯ ПО
  ИНДИВИДУАЛЬНОМУ СТРАХОВАНИЮ И СТРАХОВАНИЮ ОТ НЕСЧАСТНЫХ СЛУЧАЕВ (ДАЛЕЕ -
  ОБЩИХ УСЛОВИЙ СТРАХОВАНИЯ)< % } % --></span><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;border-top:none;
  border-left:none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:8.0pt;mso-ansi-language:RU'>
  <rw:field id="" src="MAIN_COVER_SUM"/><o:p></o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:8.0pt;mso-ansi-language:RU'>
  <rw:field id="" src="MAIN_COVER_PREM"/><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:26'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;border:none;
  mso-border-top-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;border:none;mso-border-top-alt:
  dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <rw:getValue id="j_has_dop" src="P_EXIST_DOP"/>
<rw:getValue id="j_has_avtopr" src="P_EXIST_AVTOPR"/>
 <% if (!j_has_dop.equals("0")) { %>
 <tr style='mso-yfti-irow:27'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>4.2 ДОПОЛНИТЕЛЬНЫЕ СТРАХОВЫЕ РИСКИ:<o:p></o:p></span></b></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:28;'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;border:none;
  border-bottom:none;mso-border-bottom-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;border:none;border-bottom:none;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <% } %>

 <!-- ######################################################################## -->
 <rw:foreach id="fi1" src="g_dop_summ">

 <tr style='mso-yfti-irow:33;'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-left:12.6pt;text-indent:-12.6pt'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><span style='mso-spacerun:yes'> 
  </span><rw:field id="" src="dop_progr"/></span></p>
  </td>

  <td width=143 colspan=2 valign=top style='width:107.5pt;border-top:dashed windowtext 1.0pt;
  border-left:none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><rw:getValue id="j_need_x" src="need_x"/><% if (j_need_x.equals("1")) { %>X<% } else { %><rw:field id="" src="dop_summ"/><% } %></span></b></p>
  </td>
  
  <td width=110 valign=top style='width:82.2pt;border-top:dashed windowtext 1.0pt;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><rw:field id="" src="dop_prem"/></span></b></p>
  </td>
 </tr>

 <tr style='mso-yfti-irow:34;'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;border:none;
  mso-border-top-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;border:none;mso-border-top-alt:
  dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>

 </rw:foreach>
 <!-- ######################################################################## -->


 
 <!-- СТРАХОВАНИЕ ОТ НЕСЧАСТНЫХ СЛУЧАЕВ -->
 <rw:getValue id="j_has_ns" src="P_EXIST_DOP_NS"/>
 <% if (!j_has_ns.equals("0")) { %>
 
 <tr style='mso-yfti-irow:35;'>
  
  <td width=143 colspan=2 valign=top style='width:107.5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><span style='mso-spacerun:yes'> </span><o:p></o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><span style='mso-spacerun:yes'> </span><o:p></o:p></span></b></p>
  </td>
 </tr>
 

 <!-- / СТРАХОВАНИЕ ОТ НЕСЧАСТНЫХ СЛУЧАЕВ -->
 
 <rw:foreach id="fi_ds_ns" src="G_dop_summ_ns"> 
 <tr style='mso-yfti-irow:39;'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-left:12.6pt;text-indent:-12.6pt'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><span
  style='mso-spacerun:yes'>        </span><rw:field id="" src="dop_progr_ns"/></span></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;border-top:dashed windowtext 1.0pt;
  border-left:none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><rw:field id="" src="dop_summ_ns"/></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;border-top:dashed windowtext 1.0pt;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><rw:field id="" src="dop_prem_ns"/></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:40'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;border:none;
  mso-border-top-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;border:none;mso-border-top-alt:
  dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 </rw:foreach>
 <% } %>
 
 <!-- ######################################################################## -->
 
 <!--rw:foreach id="fi_ds_ns" src="G_dop_summ_ns"--> 
 <tr style='mso-yfti-irow:41;' >
  <td width=455 colspan=2 valign=top style='width:341.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:42'>
  <td width=598 colspan=4 valign=top style='width:448.8pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt;mso-ansi-language:RU'><a
  name="ns_ins"></a><span style='mso-spacerun:yes'> </span>СТРАХОВОЙ ВЗНОС (ПРЕМИЯ):<span
  style='mso-spacerun:yes'>   </span><a name=program><span
  style='mso-spacerun:yes'> </span><% if (!j_has_dop.equals("0")) { %><% } else { %><% } %> </a> <i
  style='mso-bidi-font-style:normal'>(уплачивается <rw:field id="" src="PA_PERIODICH"/>)</i>:<o:p></o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><rw:field id="" src="ITOGO_PREM"/></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:43;height:3.5pt'>
  <td width=467 colspan=3 valign=top style='width:350.3pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:3.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=131 valign=top style='width:98.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:44'>
  <td width=598 colspan=4 valign=top style='width:448.8pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt;mso-ansi-language:RU'><span
  style='mso-spacerun:yes'>                        </span>АДМИНИСТРАТИВНЫЕ
  ИЗДЕРЖКИ </span></b><span style='font-size:8.0pt;mso-ansi-language:RU;
  mso-bidi-font-weight:bold'>(</span><b style='mso-bidi-font-weight:normal'><i
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'>уплачивается <a name="charge_period">ежегодно</a></span></i></b><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'>):<o:p></o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><rw:field id="" src="ADMIN_PAY"/></span></b></p>
  </td>

 <rw:getValue id="curr" src="CUR_POLICY"/>
</tr>
 <tr style='mso-yfti-irow:45;page-break-inside:avoid;height:17.05pt'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.05pt'>
  <p class=MsoNormal style='margin-top:6.0pt'><a name="currency_phrase"><i><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU;
  mso-no-proof:yes'><span style='mso-spacerun:yes'> </span></span></i></a><i><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU;
  mso-no-proof:yes'><% if (!curr.equals("122")) { %> Рублевый эквивалент премии уплачивается по курсу ЦБ РФ, установленному
 для соответствующей валюты на дату уплаты. Все банковские расходы, связанные с оплатой страховой
  премии, оплачиваются Страхователем. <% } else { %> Все банковские расходы, связанные с оплатой страховой
  премии, оплачиваются Страхователем. <% } %></span></i><b style='mso-bidi-font-weight:
  normal'><i><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></i></b></p>
  </td>
 </tr>

 <!--tr style='mso-yfti-irow:46;mso-yfti-lastrow:yes;height:2.2pt'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.2pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr-->
</table>

<p class=MsoNormal><span lang=EN-US><o:p>&nbsp;</o:p></span></p>

<span lang=EN-US style='font-size:12.0pt;font-family:"Times New Roman";
mso-fareast-font-family:"Times New Roman";mso-ansi-language:EN-US;mso-fareast-language:
EN-US;mso-bidi-language:AR-SA'><br clear=all style='mso-special-character:line-break;
page-break-before:always'>
</span>

<p class=MsoNormal><span lang=EN-US><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=708
 style='width:531.0pt;mar-gin-left:-48.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:2.0pt;'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
<br></br>

  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600;mso-ansi-language:RU'>5. СРОК ДЕЙСТВИЯ ДОГОВОРА СТРАХОВАНИЯ </span></b><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:2.0pt;'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>

 <!-- ######################################## -->
 <rw:foreach id="f_years" src="g_years">
 
 <tr style='mso-yfti-irow:2;height:2.0pt;'>
  <td width=192 valign=top style='width:144.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>СРОК ДЕЙСТВИЯ ДОГОВОРА:<o:p></o:p></span></b></p>
  </td>
  <td width=60 valign=top style='width:45.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal style='tab-stops:center 17.1pt'><span style='font-size:
  8.0pt;mso-ansi-language:RU'><span style='mso-tab-count:1'></span><rw:field id="" src="CF_YEAR"/></span></p>
  </td>
  <td width=71 colspan=3 valign=top style='width:53.3pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'>НАЧАЛО:<o:p></o:p></span></b></p>
  </td>
  <td width=121 colspan=3 valign=top style='width:110.7pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><rw:field id="" src="CF_START_DATE"/></span></p>
  </td>
  <td width=95 colspan=2 valign=top style='width:71.4pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'>ОКОНЧАНИЕ:<o:p></o:p></span></b></p>
  </td>
  <td width=169 colspan=2 valign=top style='width:106.6pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt;
  mso-ansi-language:RU'><rw:field id="" src="CF_END_DATE"/></span></p>
  </td>
 </tr>

 <tr style='mso-yfti-irow:3;height:2.0pt;'>
  <td width=192 valign=top style='width:144.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  mso-ansi-language:RU'><rw:field id="" src="CF_COVER_LIST"/></span></p>
  </td>
  <td width=60 valign=top style='width:45.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  mso-ansi-language:RU'><span style='mso-spacerun:yes'> </span><o:p></o:p></span></p>
  </td>
  <td width=71 colspan=3 valign=top style='width:53.3pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  mso-ansi-language:RU'><span style='mso-spacerun:yes'> </span><o:p></o:p></span></p>
  </td>
  <td width=121 colspan=3 valign=top style='width:110.7pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  mso-ansi-language:RU'><span style='mso-spacerun:yes'> </span><o:p></o:p></span></p>
  </td>
  <td width=95 colspan=2 valign=top style='width:71.4pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  mso-ansi-language:RU'><span style='mso-spacerun:yes'> </span><o:p></o:p></span></p>
  </td>
  <td width=169 colspan=2 valign=top style='width:106.6pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  mso-ansi-language:RU'><span style='mso-spacerun:yes'> </span><o:p></o:p></span></p>
  </td>
 </tr>
 
 </rw:foreach>
 <!-- ######################################## -->
  <% if (!j_has_avtopr.equals("0")) { %>
 
 <tr style='mso-yfti-irow:6;height:3.15pt;'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.15pt'>
  <p class=MsoNormal style='margin-top:12.0pt;text-align:justify'><a
  name="print_days"><b style='mso-bidi-font-weight:normal'><i><span
  style='font-size:8.0pt;mso-ansi-language:RU'>Если Страхователь за 30
  (тридцать) календарных дней до дня окончания срока страхования по
  дополнительным программам <span style='mso-bidi-font-weight:bold'></span> не выразит желания исключить какую-либо из указанных<span
  style='mso-spacerun:yes'>  </span>программ<span style='mso-spacerun:yes'> 
  </span>из настоящего Договора или не предложит иные условия, при условии
  своевременной оплаты Страхователем очередной премии, указанной в п.№ </span></i></b></span><span
  style='mso-bookmark:print_days'><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU;mso-bidi-font-style:italic'>4<i>
  настоящего полиса, срок страхования по указанной(ым) дополнительной(ым)
  программе(ам) будет считаться пролонгированным на 1 год на прежних условиях
  соответствующей дополнительной программы.</i></span></b></span><b
  style='mso-bidi-font-weight:normal'><i><span style='font-size:9.0pt;
  mso-bidi-font-size:12.0pt;mso-ansi-language:RU;mso-no-proof:yes'><o:p></o:p></span></i></b></p>
  </td> 
 </tr>
  <% } %>
  
 <tr style='mso-yfti-irow:7;height:3.15pt;'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.15pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8;'>
  <td width=467 colspan=9 valign=top style='width:350.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600;mso-ansi-language:RU'>6. УСЛОВИЯ И СРОКИ УПЛАТЫ СТРАХОВОЙ<span
  style='mso-spacerun:yes'>  </span>ПРЕМИИ</span></b><b style='mso-bidi-font-weight:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:
  RU'><o:p></o:p></span></b></p>
  </td>
  <td width=131 colspan=2 valign=top style='width:98.5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:9'>
  <td width=300 colspan=4 valign=top style='width:225.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=48 colspan=2 valign=top style='width:36.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=250 colspan=5 valign=top style='width:187.8pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:10'>
  <td width=300 colspan=4 valign=top style='width:225.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>ДАТА УПЛАТЫ ПЕРВОГО СТРАХОВОГО ВЗНОСА:<o:p></o:p></span></b></p>
  </td>
  <td width=408 colspan=8 valign=top style='width:306.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><rw:field id="" src="FIRST_PAY"/></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:11'>
  <td width=467 colspan=9 valign=top style='width:350.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:3.0pt;mso-ansi-language:RU;
  mso-no-proof:yes'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=131 colspan=2 valign=top style='width:98.5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:12'>
  <td width=300 colspan=4 valign=top style='width:225.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><a name="payment_rule_row"><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt;mso-ansi-language:RU'>ДАТА УПЛАТЫ ПОСЛЕДУЮЩИХ СТРАХОВЫХ ВЗНОСОВ:</span></b></a><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p></o:p></span></b></p>
  </td>
  <td width=408 colspan=8 valign=top style='width:306.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><rw:field id="" src="NEXT_PAYS"/> каждого последующего года срока страхования <b
  style='mso-bidi-font-weight:normal'><o:p></o:p></b></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:13'>
  <td width=395 colspan=7 valign=top style='width:296.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;color:#FF6600;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=203 colspan=4 valign=top style='width:152.5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:14'>
  <td width=395 colspan=7 valign=top style='width:296.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><a name="no_benefit"><b><span style='font-size:9.0pt;
  mso-bidi-font-size:8.0pt;color:#FF6600;mso-ansi-language:RU'>7.
  ВЫГОДОПРИОБРЕТАТЕЛИ НА СЛУЧАЙ<span style='mso-spacerun:yes'>  </span>СМЕРТИ</span></b></a><span
  style='mso-bookmark:no_benefit'><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:no_benefit'></span>
  <td width=203 colspan=4 valign=top style='width:152.5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:15;'>
  <td width=395 colspan=7 valign=top style='width:296.3pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:no_benefit'></span>
  <p class=MsoNormal><span style='mso-bookmark:no_benefit'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:no_benefit'></span>
  <td width=203 colspan=4 valign=top style='width:152.5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:16;'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:dashed windowtext 1.0pt;'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:no_benefit'><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>Ф.И.О.<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:no_benefit'></span>
  <td width=131 colspan=4 valign=top style='width:98.3pt;padding:0cm 5.4pt 0cm 5.4pt;border:dashed windowtext 1.0pt;'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'>ДАТА РОЖДЕНИЯ<o:p></o:p></span></b></p>
  </td>
  <td width=203 colspan=4 valign=top style='width:152.5pt;padding:0cm 5.4pt 0cm 5.4pt;border:dashed windowtext 1.0pt;'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'>РОДСТВЕННЫЕ ОТНОШЕНИЯ<o:p></o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;padding:0cm 5.4pt 0cm 5.4pt;border:dashed windowtext 1.0pt;'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'>ДОЛЯ<o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:17;'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;border:dashed windowtext 1.0pt;
  border-bottom:dashed windowtext 1.0pt;mso-border-bottom-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'><span style='mso-bookmark:no_benefit'></span>
  <p class=MsoNormal><span style='mso-bookmark:no_benefit'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:3.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:no_benefit'></span>
  <td width=131 colspan=4 valign=top style='width:98.3pt;border:dashed windowtext 1.0pt;
  border-bottom:dashed windowtext 1.0pt;mso-border-bottom-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:3.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=203 colspan=4 valign=top style='width:152.5pt;border:dashed windowtext 1.0pt;
  border-bottom:dashed windowtext 1.0pt;mso-border-bottom-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;border:none;border:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 
 <rw:foreach id="fi_benefit" src="G_beneficiary">
 <tr style='mso-yfti-irow:18;'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;border:dashed windowtext 1.0pt;
  border-top:none;mso-border-top-alt:dashed windowtext .5pt;mso-border-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:no_benefit'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><rw:field id="" src="beneficiary"/></span></span></p>
  </td>
  <span style='mso-bookmark:no_benefit'></span>
  <td width=131 colspan=4 valign=top style='width:98.3pt;border-top:none;
  border-left:none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><rw:field id="" src="ben_birth"/></span></p>
  </td>
  <td width=203 colspan=4 valign=top style='width:152.5pt;border-top:none;
  border-left:none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><rw:field id="" src="ben_rel"/></span></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><rw:field id="" src="ben_part"/></span></p>
  </td>
 </tr>
 </rw:foreach>

 <tr style='mso-yfti-irow:19;page-break-before:always;'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;border:none;
  mso-border-top-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:no_benefit'></span>
  <p class=MsoNormal><span style='mso-bookmark:no_benefit'><b><span
  style='font-size:8.0pt;color:#FF6600;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:no_benefit'></span>
 </tr>
 <tr style='mso-yfti-irow:20'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
<br></br>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600;mso-ansi-language:RU'>8. ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ</span></b><span
  style='font-size:9.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
 </tr>

 <tr style='mso-yfti-irow:21;page-break-inside:avoid;height:1.9pt'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:1.9pt'>
  <p class=MsoNormal style='margin-left:5.4pt;text-indent:-5.4pt'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>

 
 <rw:foreach id="fi_dop_uslov" src="G_text">
 <tr style='mso-yfti-irow:22'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-left:9.0pt;text-indent:-9.0pt'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><rw:field id="" src="text"/></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:23;page-break-inside:avoid;height:1.0pt'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:1.9pt'>
  <p class=MsoNormal style='margin-left:5.4pt;text-indent:-5.4pt'><span
  style='font-size:5.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
 
 <tr style='mso-yfti-irow:33'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></p>
  </td>
  <td width=444 colspan=9 valign=top style='width:333.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></p>
  </td>
 </tr>

<%
  DecimalFormatSymbols unusualSymbols =  new DecimalFormatSymbols();
  unusualSymbols.setDecimalSeparator('.');
  String strange = "0";
  DecimalFormat format = new DecimalFormat(strange, unusualSymbols);  
  
  double NN = 1;
%> 
 
 <tr style='mso-yfti-irow:34'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>К полису прилагаются:<o:p></o:p></span></i></p>
  </td>
  <td width=444 colspan=9 valign=top style='width:333.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><% if (!jProdBrief.equals("TERM") ) { %><%=format.format(NN++)%>. Таблица выкупных сумм по
  основной программе (Приложение № 1)<% } else { %>&nbsp;<% } %><o:p></o:p></span></i></p>
  </td>
 </tr>

<rw:foreach id="fi2" src="g_dop_summ">
<rw:getValue id="j_inv" src="dop_inv"/>


 <tr style='mso-yfti-irow:35'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'></span></i></p>
  </td>
  <td width=444 colspan=9 valign=top style='width:333.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><% if (j_inv.equals("1")) { %><%=format.format(NN++)%>. Таблица выкупных сумм по
  программе ИНВЕСТ (Приложение № 2)<% } else { %><% } %><o:p><o:p/></span></i></p>
  </td>
 </tr>
</rw:foreach>


 <tr style='mso-yfti-irow:36'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></p>
  </td>
  <td width=444 colspan=9 valign=top style='width:333.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><%=format.format(NN++)%>. Заявление на страхование
  №<span style='mso-spacerun:yes'>  </span><rw:field id="" src="P_NOTICE"/></span></i></p>
  </td>
 </tr>
 
 <tr style='mso-yfti-irow:38'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=444 colspan=9 valign=top style='width:333.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><%=format.format(NN++)%>. Полисные условия к программе страхования "Семейный депозит"</span></i></p>
  </td>
 </tr>

  <rw:getValue id="j_P_TEL_VRED" src="P_TEL_VRED"/>
  <% if (j_P_TEL_VRED.equals("1")) { %>
 <tr style='mso-yfti-irow:38'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=444 colspan=9 valign=top style='width:333.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><%=format.format(NN++)%>. Таблица выплат по страховому риску "Телесные повреждения в результате несчастного случая"</i></p>
  </td>
 </tr>
 <% } %>
 <tr style='mso-yfti-irow:39;mso-yfti-lastrow:yes;height:33.35pt'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:33.35pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>СТРАХОВАТЕЛЬ<o:p></o:p></span></b></p>
  <div style='mso-element:para-border-div;border:none;border-bottom:solid windowtext 1.5pt;
  padding:0cm 0cm 1.0pt 0cm'>
  <p class=MsoNormal style='border:none;mso-border-bottom-alt:solid windowtext 1.5pt;
  padding:0cm;mso-padding-alt:0cm 0cm 1.0pt 0cm'><b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal style='border:none;mso-border-bottom-alt:solid windowtext 1.5pt;
  padding:0cm;mso-padding-alt:0cm 0cm 1.0pt 0cm'><b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal style='border:none;mso-border-bottom-alt:solid windowtext 1.5pt;
  padding:0cm;mso-padding-alt:0cm 0cm 1.0pt 0cm'><b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal style='border:none;mso-border-bottom-alt:solid windowtext 1.5pt;
  padding:0cm;mso-padding-alt:0cm 0cm 1.0pt 0cm'><b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></b></p>
  </div>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=444 colspan=9 valign=top style='width:333.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:33.35pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'></span></p>
  </td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=192 style='border:none'></td>
  <td width=60 style='border:none'></td>
  <td width=12 style='border:none'></td>
  <td width=36 style='border:none'></td>
  <td width=23 style='border:none'></td>
  <td width=25 style='border:none'></td>
  <td width=47 style='border:none'></td>
  <td width=49 style='border:none'></td>
  <td width=23 style='border:none'></td>
  <td width=72 style='border:none'></td>
  <td width=59 style='border:none'></td>
  <td width=110 style='border:none'></td>
 </tr>
 <![endif]>
</table>

<p class=MsoNormal style='tab-stops:100.5pt'><span style='mso-ansi-language:
RU;mso-no-proof:yes'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=710
 style='width:532.3pt;mar-gin-left:-48.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=264 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>ФИО Консультанта<o:p></o:p></span></i></p>
  </td>
  <td width=446 valign=top style='width:334.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><rw:field id="" src="PA_CURATOR"/></span></i></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=264 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>Номер Консультанта<o:p></o:p></span></i></p>
  </td>
  <td width=446 valign=top style='width:334.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><rw:field id="" src="PA_TABNUM"/></span></i></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=264 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></p>
  </td>
  <td width=446 valign=top style='width:334.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes'>
  <td width=264 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i><span style='font-size:8.0pt;mso-ansi-language:RU'>Москва, Дата выдачи полиса: <rw:field id="" src="PRINT_DATE_CHAR"/></span></i></p>
  </td>
  <td width=446 valign=top style='width:334.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></p>
  </td>
 </tr>
</table>

<p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

</div>


<% if (!jProdBrief.equals("TERM") ) { %>
<span style='font-size:12.0pt;font-family:"Times New Roman";mso-fareast-font-family:
"Times New Roman";mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:
AR-SA'><br clear=all style='page-break-before:always;mso-break-type:section-break'>
</span>

<div class=Section2 style='padding-left:1cm;'>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;mar-gin-left:-12.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  page-break-inside:avoid'>
  <td width=626 valign=top style='width:469.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><a name="table_sum"><span style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></a></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
  style='mso-ansi-language:RU'>ПРИЛОЖЕНИЕ № 1<o:p></o:p></span></b></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><i style='mso-bidi-font-style:normal'><span
  style='font-size:9.0pt;mso-ansi-language:RU'>Является составной и
  неотъемлемой частью полиса<span style='mso-spacerun:yes'>  </span>№ <rw:field id="" src="pol_num"/><o:p></o:p></span></i></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
  style='mso-ansi-language:RU'>ТАБЛИЦА ВЫКУПНЫХ СУММ ПО<span
  style='mso-spacerun:yes'>  </span>ОСНОВНОМУ РИСКУ <o:p></o:p></span></b></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></span></p>
  <span style='mso-bookmark:table_sum'></span>
  <p class=MsoNormal style='margin-right:4.55pt'><span style='mso-bookmark:
  table_sum'><b style='mso-bidi-font-weight:normal'><span style='font-size:
  8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
 </tr>
</table>

<p class=MsoNormal style='margin-right:4.55pt;line-height:1.0pt;mso-line-height-rule:
exactly;tab-stops:77.4pt 176.4pt 243.75pt 329.4pt 456.6pt'><span
style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
style='font-size:8.0pt;mso-ansi-language:RU'><span style='mso-tab-count:4'>                                                                                                                                                  </span><o:p></o:p></span></b></span></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;mar-gin-left:-12.6pt;border-collapse:collapse;border:none;
 mso-border-alt:dashed windowtext .5pt;mso-yfti-tbllook:480;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt;mso-border-insideh:.5pt dashed windowtext;mso-border-insidev:
 .5pt dashed windowtext'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
   <td width=120 valign=top style='width:90.0pt;border:dashed windowtext 1.0pt;
   mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
   style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-ansi-language:RU'>ГОД ДЕЙСТВИЯ ДОГОВОРА<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:table_sum'></span>
   <td width=132 valign=top style='width:99.0pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dashed windowtext .5pt;mso-border-alt:
   dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
   style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-ansi-language:RU'>НОМЕР ПЕРИОДА<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:table_sum'></span>
   <td width=90 valign=top style='width:67.35pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dashed windowtext .5pt;mso-border-alt:
   dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
   style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-ansi-language:RU'>НАЧАЛО<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:table_sum'></span>
   <td width=114 valign=top style='width:85.65pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dashed windowtext .5pt;mso-border-alt:
   dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
   style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-ansi-language:RU'>ОКОНЧАНИЕ<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:table_sum'></span>
   <td width=170 valign=top style='width:127.2pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dashed windowtext .5pt;mso-border-alt:
   dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
   style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-ansi-language:RU'>ВЫКУПНАЯ СУММА, <a
   name="currency_3"><rw:field id="" src="PA_KOD_VAL_UP"/></a><o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:table_sum'></span>
  </tr>
 </thead>
 
 <rw:foreach id="f_insyearnum" src="G_INSURANCE_YEAR_NUMBER">
 <tr style='mso-yfti-irow:1;height:11.35pt;'>
  <td width=120 style='width:90.0pt;border:dashed windowtext 1.0pt;border-top:
  none;mso-border-top-alt:dashed windowtext .5pt;mso-border-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="YEAR_NUMBER"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=132 style='width:99.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="N"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=90 style='width:67.35pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_START"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_END"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=170 style='width:127.2pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="RANSOM"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
 </tr>
 </rw:foreach>

</table>

 <rw:foreach id="f_insyearnum_d" src="G_INSURANCE_YEAR_NUMBER_d">
 <rw:getValue id="nn" src="n_d"/>

<% if (nn.equals("48") ) { %>

<span style='font-size:12.0pt;font-family:"Times New Roman";mso-fareast-font-family:
"Times New Roman";mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:
AR-SA'><br clear=all style='page-break-before:always;mso-break-type:section-break'>
</span>
<p class=MsoNormal style='margin-right:4.55pt;line-height:1.0pt;mso-line-height-rule:
exactly;tab-stops:77.4pt 176.4pt 243.75pt 329.4pt 456.6pt'><span
style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
style='font-size:8.0pt;mso-ansi-language:RU'><span style='mso-tab-count:4'>                                                                                                                                                  </span><o:p></o:p></span></b></span></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;mar-gin-left:-12.6pt;border-collapse:collapse;border:none;
 mso-border-alt:dashed windowtext .5pt;mso-yfti-tbllook:480;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt;mso-border-insideh:.5pt dashed windowtext;mso-border-insidev:
 .5pt dashed windowtext'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
   <td width=120 valign=top style='width:90.0pt;border:dashed windowtext 1.0pt;
   mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
   style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-ansi-language:RU'>ГОД ДЕЙСТВИЯ ДОГОВОРА<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:table_sum'></span>
   <td width=132 valign=top style='width:99.0pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dashed windowtext .5pt;mso-border-alt:
   dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
   style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-ansi-language:RU'>НОМЕР ПЕРИОДА<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:table_sum'></span>
   <td width=90 valign=top style='width:67.35pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dashed windowtext .5pt;mso-border-alt:
   dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
   style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-ansi-language:RU'>НАЧАЛО<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:table_sum'></span>
   <td width=114 valign=top style='width:85.65pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dashed windowtext .5pt;mso-border-alt:
   dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
   style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-ansi-language:RU'>ОКОНЧАНИЕ<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:table_sum'></span>
   <td width=170 valign=top style='width:127.2pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dashed windowtext .5pt;mso-border-alt:
   dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
   style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-ansi-language:RU'>ВЫКУПНАЯ СУММА, <a
   name="currency_3"><rw:field id="" src="PA_KOD_VAL_UP"/></a><o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:table_sum'></span>
  </tr>
 </thead>

<% } %>
 </rw:foreach>
 

 <rw:foreach id="f_insyearnum_d1" src="G_INSURANCE_YEAR_NUMBER_d">

 <tr style='mso-yfti-irow:1;height:11.35pt;'>
  <td width=120 style='width:90.0pt;border:dashed windowtext 1.0pt;border-top:
  none;mso-border-top-alt:dashed windowtext .5pt;mso-border-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="YEAR_NUMBER_d"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=132 style='width:99.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="N_d"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=90 style='width:67.35pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_START_d"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_END_d"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=170 style='width:127.2pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="RANSOM_d"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
 </tr>

 </rw:foreach>


</table>





</div>
<% } //печатать ли таблицу выкупн. сумм %>


<rw:foreach id="fi3" src="g_dop_summ">
<rw:getValue id="j_inv_1" src="dop_inv"/>
<% if (j_inv_1.equals("1")) { %>

<span style='font-size:12.0pt;font-family:"Times New Roman";mso-fareast-font-family:
"Times New Roman";mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:
AR-SA'><br clear=all style='page-break-before:always;mso-break-type:section-break'>
</span>

<div class=Section3 style='padding-left:1cm;'>


<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;mar-gin-left:-12.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  page-break-inside:avoid'>
  <td width=626 valign=top style='width:469.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><a name="table_sum"><span style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></a></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
  style='mso-ansi-language:RU'>ПРИЛОЖЕНИЕ № 2<o:p></o:p></span></b></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><i style='mso-bidi-font-style:normal'><span
  style='font-size:9.0pt;mso-ansi-language:RU'>Является составной и
  неотъемлемой частью полиса<span style='mso-spacerun:yes'>  </span>№ <rw:field id="" src="pol_num"/><o:p></o:p></span></i></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
  style='mso-ansi-language:RU'>ТАБЛИЦА ВЫКУПНЫХ СУММ ПО<span
  style='mso-spacerun:yes'>  </span>ДОПОЛНИТЕЛЬНОЙ ПРОГРАММЕ ИНВЕСТ<o:p></o:p></span></b></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></span></p>
  <span style='mso-bookmark:table_sum'></span>
  <p class=MsoNormal style='margin-right:4.55pt'><span style='mso-bookmark:
  table_sum'><b style='mso-bidi-font-weight:normal'><span style='font-size:
  8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
 </tr>
</table>


<p class=MsoNormal style='margin-right:4.55pt;line-height:1.0pt;mso-line-height-rule:
exactly;tab-stops:77.4pt 176.4pt 243.75pt 329.4pt 456.6pt'><span
style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
style='font-size:8.0pt;mso-ansi-language:RU'><span style='mso-tab-count:4'>                                                                                                                                                  </span><o:p></o:p></span></b></span></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;mar-gin-left:-12.6pt;border-collapse:collapse;border:none;
 mso-border-alt:dashed windowtext .5pt;mso-yfti-tbllook:480;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt;mso-border-insideh:.5pt dashed windowtext;mso-border-insidev:
 .5pt dashed windowtext'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
   <td width=120 valign=top style='width:90.0pt;border:dashed windowtext 1.0pt;
   mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
   style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-ansi-language:RU'>ГОД ДЕЙСТВИЯ ДОГОВОРА<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:table_sum'></span>
   <td width=132 valign=top style='width:99.0pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dashed windowtext .5pt;mso-border-alt:
   dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
   style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-ansi-language:RU'>НОМЕР ПЕРИОДА<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:table_sum'></span>
   <td width=90 valign=top style='width:67.35pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dashed windowtext .5pt;mso-border-alt:
   dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
   style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-ansi-language:RU'>НАЧАЛО<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:table_sum'></span>
   <td width=114 valign=top style='width:85.65pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dashed windowtext .5pt;mso-border-alt:
   dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
   style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-ansi-language:RU'>ОКОНЧАНИЕ<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:table_sum'></span>
   <td width=170 valign=top style='width:127.2pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dashed windowtext .5pt;mso-border-alt:
   dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
   style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-ansi-language:RU'>ВЫКУПНАЯ СУММА, <a
   name="currency_3"><rw:field id="" src="PA_KOD_VAL_UP"/></a><o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:table_sum'></span>
  </tr>
 </thead>
 
 <rw:foreach id="f_insyearnum_i" src="G_INSURANCE_YEAR_NUMBER_I">
 <tr style='mso-yfti-irow:1;height:11.35pt;'>
  <td width=120 style='width:90.0pt;border:dashed windowtext 1.0pt;border-top:
  none;mso-border-top-alt:dashed windowtext .5pt;mso-border-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="YEAR_NUMBER_I"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=132 style='width:99.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="N_I"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=90 style='width:67.35pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_START_I"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_END_I"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=170 style='width:127.2pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="RANSOM_I"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
 </tr>
 </rw:foreach>

</table>

</div>

<% } else { %><% } %>
</rw:foreach>

</body>

</html>

<!--
</rw:report> 
-->

<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.DecimalFormat" %>

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
	 <userParameter name="pol_header_id" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="amount_let" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="amount_z" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="plan_date_let" datatype="character"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="gdv_let" datatype="character"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 	 
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
<userParameter name="PA_PER" datatype="number" precision="10"
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
(select round(months_between(pc.end_date,pc.start_date)/12) years,
        pc.start_date,
        pc.end_date end_date,
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

 group by plt.brief, pc.start_date,  pc.end_date) t
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
         datatype="character" width="5000" precision="10" defaultWidth="1000000"
         defaultHeight="100000" columnFlags="16" defaultLabel="Cf Cover List"
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
	 'ИНВЕСТ2',1,
	 'ИНВЕСТ2_1',1,
 	    0) as dop_inv,

--||decode(plo.appendix_description, null, '', ' ('||upper(plo.appendix_description)||')')
            decode(upper(plo.description), 
              'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ДАЛЬНЕЙШИХ ВЗНОСОВ', 1, 
              'ЗАЩИТА СТРАХОВЫХ ВЗНОСОВ', 1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ СТРАХОВЫХ ВЗНОСОВ', 1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ДАЛЬНЕЙШИХ ВЗНОСОВ РАССЧИТАННОЕ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ВЗНОСОВ РАССЧИТАННОЕ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
	'ЗАЩИТА СТРАХОВЫХ ВЗНОСОВ РАССЧИТАННАЯ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
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
 --and (pc.decline_reason_id is null or pc.decline_date is null)
and pc.decline_date is null
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief = 'OPTIONAL'
 and pl.t_lob_line_id = tll.t_lob_line_id
 and tl.t_lob_id = tll.t_lob_id
 and ig.t_insurance_group_id = tll.insurance_group_id
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
 and (ig.brief <> 'Acc'
  or (ig.brief = 'Acc' and (plo.id = 22603 or plo.description like 'Освобождение%' or plo.description like 'Защита%' or plo.description like 'Инвалидность Застрахованного по любой причине%'))) -- согласовано с Д.Ивановым! добавлено два последних or Веселуха
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
  'ДОГОВОР СТРАХОВАНИЯ ЗАКЛЮЧЕН НА ОСНОВАНИИ "ПРАВИЛ СТРАХОВАНИЯ ЖИЗНИ", УТВЕРЖДЕННЫХ ГЕНЕРАЛЬНЫМ ДИРЕКТОРОМ ООО "СК "РЕНЕССАНС ЖИЗНЬ" 30.06.2007 ГОДА.' text,
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
  'ДЛЯ РАСТОРЖЕНИЯ ДОГОВОРА СТРАХОВАНИЯ В СЛУЧАЯХ, ПРЕДУСМОТРЕННЫХ П.П. 5.8, 7.9 ПРАВИЛ, СТРАХОВЩИК ДОЛЖЕН НАПРАВИТЬ СТРАХОВАТЕЛЮ ПИСЬМЕННОЕ ИЗВЕЩЕНИЕ НЕ МЕНЕЕ ЧЕМ ЗА 21 (ДВАДЦАТЬ ОДИН) ДЕНЬ ДО ПРЕДПОЛАГАЕМОЙ ДАТЫ ПРЕКРАЩЕНИЯ ДОГОВОРА, ПРИ ЭТОМ ДОГОВОР СЧИТАЕТСЯ РАСТОРГНУТЫМ С ДАТЫ, УКАЗАННОЙ В ИЗВЕЩЕНИИ.' text,
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
 --and (pc.decline_reason_id is null or pc.decline_date is null)
and pc.decline_date is null
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief = 'OPTIONAL'
 and pl.t_lob_line_id = tll.t_lob_line_id
 and tl.t_lob_id = tll.t_lob_id
 and ig.t_insurance_group_id = tll.insurance_group_id
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
 and ig.brief = 'Acc'
 and plo.id not in (22603,32005,44179,22629,27622,27907,27624,28063,28065,28336,32005,43607,43609,44103,44131,44177,57134,57138,57738,57802,57871,57925,58264,28200) -- согласовано с Д.Ивановым! добавлено 32005,28200 Веселуха
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
    order by d.start_cash_surr_date  ) v ) where n > 47 and n <= 100]]>
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

<dataSource name="Q_7">
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
    order by d.start_cash_surr_date  ) v ) where n > 100 and n <= 152]]>
      </select>
      <displayInfo x="14.94358" y="3.99510" width="2.75177" height="0.50788"/>
      <group name="G_INSURANCE_YEAR_NUMBER_dd">
        <displayInfo x="13.62832" y="5.63997" width="5.38293" height="2.83021"
        />
        <dataItem name="PERIOD_START_dd" datatype="vchar2" columnOrder="45"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period Start dd">
          <dataDescriptor expression="PERIOD_START_dd"
           descriptiveExpression="PERIOD_START_dd" order="3" width="10"/>
        </dataItem>
        <dataItem name="PERIOD_END_dd" datatype="vchar2" columnOrder="46"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period End dd">
          <dataDescriptor expression="PERIOD_END_dd"
           descriptiveExpression="PERIOD_END_dd" order="4" width="10"/>
        </dataItem>
        <dataItem name="YEAR_NUMBER_dd" oracleDatatype="number" columnOrder="43"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Year Number dd">
          <dataDescriptor expression="YEAR_NUMBER_dd"
           descriptiveExpression="YEAR_NUMBER_dd" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="RANSOM_dd" datatype="vchar2" columnOrder="44"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ransom dd">
          <dataDescriptor expression="RANSOM_dd" descriptiveExpression="RANSOM dd"
           order="5" width="4000"/>
        </dataItem>
        <dataItem name="N_dd" oracleDatatype="number" columnOrder="42" width="22"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="N dd">
          <dataDescriptor expression="N_dd" descriptiveExpression="N_dd" order="1"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>

	<dataSource name="Q_8">
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
    order by d.start_cash_surr_date  ) v ) where n > 152]]>
      </select>
      <displayInfo x="14.94358" y="3.99510" width="2.75177" height="0.50788"/>
      <group name="G_INSURANCE_YEAR_NUMBER_g">
        <displayInfo x="13.62832" y="5.63997" width="5.38293" height="2.83021"
        />
        <dataItem name="PERIOD_START_g" datatype="vchar2" columnOrder="45"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period Start g">
          <dataDescriptor expression="PERIOD_START_g"
           descriptiveExpression="PERIOD_START_g" order="3" width="10"/>
        </dataItem>
        <dataItem name="PERIOD_END_g" datatype="vchar2" columnOrder="46"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period End g">
          <dataDescriptor expression="PERIOD_END_g"
           descriptiveExpression="PERIOD_END_g" order="4" width="10"/>
        </dataItem>
        <dataItem name="YEAR_NUMBER_g" oracleDatatype="number" columnOrder="43"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Year Number g">
          <dataDescriptor expression="YEAR_NUMBER_g"
           descriptiveExpression="YEAR_NUMBER_g" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="RANSOM_g" datatype="vchar2" columnOrder="44"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ransom g">
          <dataDescriptor expression="RANSOM_g" descriptiveExpression="RANSOM g"
           order="5" width="4000"/>
        </dataItem>
        <dataItem name="N_g" oracleDatatype="number" columnOrder="42" width="22"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="N g">
          <dataDescriptor expression="N_g" descriptiveExpression="N_g" order="1"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>


	<dataSource name="Q_5">
      <select canParse="no">
      <![CDATA[select *
	  from (select 
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
    order by d.start_cash_surr_date  ) v) where n_i <= 47]]>
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

	<dataSource name="Q_9">
      <select canParse="no">
      <![CDATA[select *
	  from (select 
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
    order by d.start_cash_surr_date  ) v) where n_i > 47 and n_i <= 100]]>
      </select>
      <displayInfo x="14.94358" y="3.99510" width="2.75177" height="0.50788"/>
      <group name="G_INSURANCE_YEAR_NUMBER_II">
        <displayInfo x="13.62832" y="5.63997" width="5.38293" height="2.83021"
        />
        <dataItem name="PERIOD_START_II" datatype="vchar2" columnOrder="45"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period Start II">
          <dataDescriptor expression="PERIOD_START_II"
           descriptiveExpression="PERIOD_START_II" order="3" width="10"/>
        </dataItem>
        <dataItem name="PERIOD_END_II" datatype="vchar2" columnOrder="46"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period End II">
          <dataDescriptor expression="PERIOD_END_II"
           descriptiveExpression="PERIOD_END_II" order="4" width="10"/>
        </dataItem>
        <dataItem name="YEAR_NUMBER_II" oracleDatatype="number" columnOrder="43"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Year Number II">
          <dataDescriptor expression="YEAR_NUMBER_II"
           descriptiveExpression="YEAR_NUMBER_II" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="RANSOM_II" datatype="vchar2" columnOrder="44"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ransom II">
          <dataDescriptor expression="RANSOM_II" descriptiveExpression="RANSOM_II"
           order="5" width="4000"/>
        </dataItem>
        <dataItem name="N_II" oracleDatatype="number" columnOrder="42" width="22"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="N II">
          <dataDescriptor expression="N_II" descriptiveExpression="N_II" order="1"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>

<dataSource name="Q_10">
      <select canParse="no">
      <![CDATA[select *
	  from (select 
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
    order by d.start_cash_surr_date  ) v) where n_i > 100 and n_i <= 152]]>
      </select>
      <displayInfo x="14.94358" y="3.99510" width="2.75177" height="0.50788"/>
      <group name="G_INSURANCE_YEAR_NUMBER_dII">
        <displayInfo x="13.62832" y="5.63997" width="5.38293" height="2.83021"
        />
        <dataItem name="PERIOD_START_dII" datatype="vchar2" columnOrder="45"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period Start dII">
          <dataDescriptor expression="PERIOD_START_dII"
           descriptiveExpression="PERIOD_START_dII" order="3" width="10"/>
        </dataItem>
        <dataItem name="PERIOD_END_dII" datatype="vchar2" columnOrder="46"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period End dII">
          <dataDescriptor expression="PERIOD_END_dII"
           descriptiveExpression="PERIOD_END_II" order="4" width="10"/>
        </dataItem>
        <dataItem name="YEAR_NUMBER_dII" oracleDatatype="number" columnOrder="43"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Year Number dII">
          <dataDescriptor expression="YEAR_NUMBER_dII"
           descriptiveExpression="YEAR_NUMBER_dII" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="RANSOM_dII" datatype="vchar2" columnOrder="44"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ransom dII">
          <dataDescriptor expression="RANSOM_dII" descriptiveExpression="RANSOM_dII"
           order="5" width="4000"/>
        </dataItem>
        <dataItem name="N_dII" oracleDatatype="number" columnOrder="42" width="22"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="N dII">
          <dataDescriptor expression="N_dII" descriptiveExpression="N_dII" order="1"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>

<dataSource name="Q_11">
      <select canParse="no">
      <![CDATA[select *
	  from (select 
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
    order by d.start_cash_surr_date  ) v) where n_i > 152]]>
      </select>
      <displayInfo x="14.94358" y="3.99510" width="2.75177" height="0.50788"/>
      <group name="G_INSURANCE_YEAR_NUMBER_dI">
        <displayInfo x="13.62832" y="5.63997" width="5.38293" height="2.83021"
        />
        <dataItem name="PERIOD_START_dI" datatype="vchar2" columnOrder="45"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period Start dI">
          <dataDescriptor expression="PERIOD_START_dI"
           descriptiveExpression="PERIOD_START_dI" order="3" width="10"/>
        </dataItem>
        <dataItem name="PERIOD_END_dI" datatype="vchar2" columnOrder="46"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period End dI">
          <dataDescriptor expression="PERIOD_END_dI"
           descriptiveExpression="PERIOD_END_I" order="4" width="10"/>
        </dataItem>
        <dataItem name="YEAR_NUMBER_dI" oracleDatatype="number" columnOrder="43"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Year Number dI">
          <dataDescriptor expression="YEAR_NUMBER_dI"
           descriptiveExpression="YEAR_NUMBER_dI" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="RANSOM_dI" datatype="vchar2" columnOrder="44"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ransom dI">
          <dataDescriptor expression="RANSOM_dI" descriptiveExpression="RANSOM_dI"
           order="5" width="4000"/>
        </dataItem>
        <dataItem name="N_dI" oracleDatatype="number" columnOrder="42" width="22"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="N dI">
          <dataDescriptor expression="N_dI" descriptiveExpression="N_dI" order="1"
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

begin
select ph.policy_header_id
into :pol_header_id
from p_pol_header ph
where ph.policy_id = :P_POLICY_ID;
exception
      when no_data_found then :pol_header_id := 1; 
end;

begin 
select amount, plan_date, gdv
into :amount_let, :plan_date_let, :gdv_let
from
(select ac.amount,
        --ac.plan_date,
        --pp.start_date,
       to_char(ac.plan_date + 45,'dd.mm.yyyy') plan_date,
       --to_char(ac.plan_date,'dd.mm.')||to_char(extract(year from ac.plan_date) + 4) gdv
	   to_char(ph.start_date,'dd.mm.')||to_char(extract(year from ph.start_date) + 4) gdv
from p_policy pp,
	 p_pol_header ph,
     doc_doc dd,
     ac_payment ac
where pp.policy_id = dd.parent_id
      and dd.child_id = ac.payment_id
      and pp.policy_id = :P_POLICY_ID
	  and ph.policy_header_id = pp.pol_header_id
      and ac.plan_date >= pp.start_date
order by ac.plan_date asc)
where rownum = 1;
exception
      when no_data_found then :amount_let := 0; :plan_date_let := ''; :gdv_let := '';
end;  

begin
select ac.amount
into :amount_z
from p_pol_header ph,
     p_policy pp,
     doc_doc dd,
     ac_payment ac,
     doc_status ds,
     doc_status_ref rf
where ph.policy_id = :P_POLICY_ID
      and pp.pol_header_id = ph.policy_header_id
      and dd.parent_id = pp.policy_id
      and ac.payment_id = dd.child_id
      and ds.document_id = ac.payment_id
      and ds.start_date = (SELECT MAX(dss.start_date)
                           FROM DOC_STATUS dss
                           WHERE dss.document_id = ac.payment_id)
      and rf.doc_status_ref_id = ds.doc_status_ref_id
      and ac.plan_date < (select p.start_date 
                          from p_policy p,
                               p_pol_addendum_type ad
                          where p.policy_id = :P_POLICY_ID
                                and ad.p_policy_id = p.policy_id
                                and ad.t_addendum_type_id = 682)
      and rf.name = 'К оплате';
exception
      when no_data_found then :amount_z := 1;
end;
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
   case when cont.contact_type_id not in (1,3,1030) then comp.addr else ent.obj_name('CONTACT_IO', pkg_policy.get_policy_holder_id(pp.policy_id)) end,
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
    case lower(vt.DESCRIPTION) when 'единовременно' then 1 else 0 end,
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
    into :BRIEF_PRODUCT,:POL_NUM,:P_NOTICE,:CUR_POLICY,:PROGRAMMA,:P_SYSDATE,:TYPE_CONT,:POL_HOLDER,:PH_BIRTH,:PH_DOC,:POL_ASS,:PA_BIRTH,:PA_DOC, :PA_PERIODICH, :PA_PER, :WAITING_PERIOD_END_DATE, :PA_ROW_PRIL, :PA_KOD_VAL,:PA_KOD_VAL_UP
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
       '"'||(plo.description)||'"'
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
   --and (pc.decline_reason_id is null or pc.decline_date is null)
and pc.decline_date is null
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
 --and (pc.decline_reason_id is null or pc.decline_date is null)
and pc.decline_date is null
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief = 'OPTIONAL'
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ';
  exception
      when no_data_found then :P_EXIST_DOP := 0; 
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
 --and (pc.decline_reason_id is null or pc.decline_date is null)
and pc.decline_date is null
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief = 'OPTIONAL'
 and pl.t_lob_line_id = tll.t_lob_line_id
 and tl.t_lob_id = tll.t_lob_id
 and ig.t_insurance_group_id = tll.insurance_group_id
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
 and ig.brief = 'Acc'
 and plo.id not in (22603,32005,44179,22629,27622,27907,27624,28063,28065,28336,32005,43607,43609,44103,44131,44177,57134,57138,57738,57802,57871,57925,58264,28200) -- согласовано с Д.Ивановым! добавлено 32005,28200 Веселуха
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
buf varchar2(1000);
begin
  
  if (:P_OSN_PROGR > 0) then begin
  
-- Выбираем все доп программы относящиеся, к данному сроку страхования  
for rec in (select decode(rownum,1,'дополнительные программы:' ||t.description,', ' || t.description) val  
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
			 --and (pc.decline_reason_id is null or pc.decline_date is null)
and pc.decline_date is null
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
    select '(основная программа)'
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
	  --and (pc.decline_reason_id is null or pc.decline_date is null)
and pc.decline_date is null
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
 return(to_char(d,'hh24:mi') || ' ' || 'часов ' || to_char(d,'dd.mm.yyyy'));
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
<!--[if !mso]>
<style>
v\:* {behavior:url(#default#VML);}
o\:* {behavior:url(#default#VML);}
w\:* {behavior:url(#default#VML);}
.shape {behavior:url(#default#VML);}
</style>
<![endif]-->
<title>Письмо клиенту </title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>V</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>V</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>1</o:TotalTime>
  <o:Created>2009-07-09T05:52:00Z</o:Created>
  <o:LastSaved>2009-07-09T05:52:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>288</o:Words>
  <o:Characters>1646</o:Characters>
  <o:Lines>13</o:Lines>
  <o:Paragraphs>3</o:Paragraphs>
  <o:CharactersWithSpaces>1931</o:CharactersWithSpaces>
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
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:1627421319 -2147483648 8 0 66047 0;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:-1610611985 1073750139 0 0 159 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:Calibri;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:2.0cm 42.5pt 21.3pt 49.65pt;
	mso-header-margin:35.4pt;
	mso-footer-margin:35.4pt;
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

<body lang=RU style='tab-interval:35.4pt'>

<div class=Section1>
<rw:getValue id="z" src="amount_z"/>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:11.0pt;font-family:Tahoma'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><span class=GramE><span
style='font-size:11.0pt;font-family:Tahoma'>Уважаемый (ая)</span></span><span
style='font-size:11.0pt;font-family:Tahoma'> <rw:field id="" src="POL_HOLDER"/>!<o:p></o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:11.0pt;font-family:Tahoma'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:11.0pt;
font-family:Tahoma'>Благодарим Вас за сотрудничество и за проявленный интерес к
нашей услуге «Финансовые каникулы». <o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:11.0pt;
font-family:Tahoma'>Приложенное дополнительное соглашение к Вашему договору
страхования № <rw:field id="" src="POL_NUM"/> выпущено Компанией на основании Вашего заявления
на предоставление «Финансовых каникул». В соответствие с данным дополнительным
соглашением Вы должны оплатить <% if (z.equals("1")) { %><% } else { %>
имеющуюся задолженность по договору в размере </span><span
lang=EN-US style='font-size:11.0pt;font-family:Tahoma;mso-ansi-language:EN-US'><rw:field id="" src="amount_z"/></span><span
style='font-size:11.0pt;font-family:Tahoma'> <span class=GramE>рублей,</span> а
также очередной<span style='mso-spacerun:yes'>  </span> <% } %> страховой взнос,
указанный в дополнительном соглашении, в размере </span><span lang=EN-US
style='font-size:11.0pt;font-family:Tahoma;mso-ansi-language:EN-US'><rw:field id="" src="amount_let"/></span><span
style='font-size:11.0pt;font-family:Tahoma'> рублей в срок до 
<rw:field id="" src="plan_date_let"/>.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:11.0pt;
font-family:Tahoma'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:11.0pt;
font-family:Tahoma'>В любую страховую годовщину, но не позднее <rw:field id="" src="gdv_let"/>, 
у Вас есть возможность возобновить действие страховых программ,
действующих по Вашему договору страхования, до вступления в силу услуги
«Финансовые каникулы». Для этого Вам необходимо будет за 30 рабочих дней до
очередной годовщины действия договора страхования заполнить заявление на
прекращение действия услуги «Финансовые каникулы». Действие программ
возобновляется по результатам оценки страхового риска и в соответствие с
порядками и условиями, установленными Компанией. Шаблон Заявления и
дополнительную информацию Вы можете получить, обратившись к Вашему финансовому
консультанту, либо позвонив по телефону +7 (495) 981-2-981.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:11.0pt;
font-family:Tahoma'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:11.0pt;
font-family:Tahoma'>Ниже представлен график изменения страховой суммы по
программе <rw:field id="" src="MAIN_COVER"/>, в зависимости от даты
прекращения действия услуги «Финансовые каникулы», а также мы отразили
преимущество сохранения договора страхования, сравнив страховую сумму
восстановленной программы и страховую сумму по аналогичной программе в случае
заключения нового договора страхования*.</span><span lang=EN-US
style='font-size:11.0pt;font-family:Tahoma;mso-ansi-language:EN-US'><o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span lang=EN-US
style='font-size:11.0pt;font-family:Tahoma;mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:center'><span lang=EN-US
style='font-size:11.0pt;font-family:Tahoma;mso-ansi-language:EN-US'>Изменение страховых сумм
по программе<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:center'><span lang=EN-US
style='font-size:11.0pt;font-family:Tahoma;mso-ansi-language:EN-US'><rw:field id="" src="MAIN_COVER"/><o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:3.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>
<img width=400 height=350 src="<%=g_ImagesRoot%>/letter_remind/image012.jpg" alt="картинка в письмо"></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify'>*<i><span style='font-size:10.0pt;
font-family:Tahoma'>Данный расчет сделан на примере среднестатистического договора страхования
портфеля Компании.<o:p></o:p></span></i></p>

</div>

</body>

</html>

<!--
</rw:report> 
-->

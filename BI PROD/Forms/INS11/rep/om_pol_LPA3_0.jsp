<%@ taglib uri="/WEB-INF/lib/reports_tld.jar" prefix="rw" %> 
<%@ page language="java" import="java.io.*" errorPage="/rwerror.jsp" session="false" %>
<%@ page import="java.text.*" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<%
  double RESERVE_PRIL = 0;  
%>
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
	<userParameter name="pol_head_id" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="ff" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="flg" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="ver_num" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="v_fee1" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="v_fee2" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="v_wed" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="v_ad" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="PRINT_DATE_VIPL" datatype="character"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	<userParameter name="PH_BIRTH" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PA_DOC" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="PA_DAYS" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="addendum_note" datatype="character" width="4000"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="asset_id" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="seria" datatype="character" width="400"
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
	  <userParameter name="POLICY_NUMBER" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="Y" datatype="character" width="400"
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
	<userParameter name="P_EXIST_DOP_RESERVE" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="TO_PAY_RESERVE" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="PAID_RESERVE" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
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
      
select years, start_date, end_date, brief, dd from 
(select round(months_between(pc.end_date,pc.start_date)/12) years,
        pc.start_date,
        pc.end_date end_date,
        plt.brief,
		decode(plo.description, 'Первичное диагностирование смертельно опасного заболевания', 2,
                               'ИНВЕСТ', 2,
                               'ИНВЕСТ2',2,
                               'ИНВЕСТ2_1',2,
                               'Страхование жизни на срок',2,
                               3) || decode(plt.brief, 'OPTIONAL', 2, 1) dd
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

 group by plt.brief, pc.start_date,  pc.end_date,
 decode(plo.description, 'Первичное диагностирование смертельно опасного заболевания', 2,
                               'ИНВЕСТ', 2,
                               'ИНВЕСТ2',2,
                               'ИНВЕСТ2_1',2,
                               'Страхование жизни на срок',2,
                               3) || decode(plt.brief, 'OPTIONAL', 2, 1)) t
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
         datatype="character" width="1000" precision="10" defaultWidth="100000"
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
		<dataItem name="dd" oracleDatatype="number" columnOrder="70"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="dd">
          <dataDescriptor expression="dd" descriptiveExpression="dd"
           order="5" oracleDatatype="number" width="22" precision="38"/>
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
where pp.policy_id = :P_POLICY_ID
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
    <dataSource name="Q_2">
      <select>
      <![CDATA[-- Доплнительные программы
select pkg_rep_utils.to_money_sep(pc.ins_amount) as dop_summ,
       pkg_rep_utils.to_money_sep(pc.fee) as dop_prem,
       '* "'||decode(plo.description,'Дополнительный инвестиционный доход','ИНВЕСТ',
							         'Освобождение от уплаты дальнейших взносов рассчитанное по основной программе','ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ СТРАХОВЫХ ВЗНОСОВ',
									 'Освобождение от уплаты взносов рассчитанное по основной программе','ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ СТРАХОВЫХ ВЗНОСОВ',
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
 --and (pc.decline_reason_id is null or pc.decline_date is null)
and pc.decline_date is null
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief in ('OPTIONAL','MANDATORY')
 and pl.t_lob_line_id = tll.t_lob_line_id
 and tl.t_lob_id = tll.t_lob_id
 and ig.t_insurance_group_id = tll.insurance_group_id
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
 and ((ig.brief <> 'Acc' AND pl.t_lob_line_id NOT IN (SELECT ll.t_lob_line_id
                              						 FROM ins.t_lob_line ll
                              						 WHERE ll.brief = 'PEPR_INVEST_RESERVE'
                              						 )
	  )
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
  'ДОГОВОР СТРАХОВАНИЯ ЗАКЛЮЧЕН НА ОСНОВАНИИ "ПОЛИСНЫХ УСЛОВИЙ К ДОГОВОРУ СТРАХОВАНИЯ ЖИЗНИ ПО ПРОГРАММАМ СТРАХОВАНИЯ ЖИЗНИ "ГАРМОНИЯ ЖИЗНИ", "СЕМЬЯ", "ДЕТИ", "БУДУЩЕЕ", УТВЕРЖДЕННЫХ ГЕНЕРАЛЬНЫМ ДИРЕКТОРОМ ООО "СК "РЕНЕССАНС ЖИЗНЬ" 01.04.2009 ГОДА.' text,
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
  'ВРЕМЯ ДЕЙСТВИЯ СТРАХОВОЙ ЗАЩИТЫ: 24 ЧАСА В СУТКИ.' text,
  '*' prog
  from dual
  union all
  select
  'ПРИ ДОСРОЧНОМ  РАСТОРЖЕНИИ ДОГОВОРА ВЫПЛАТА ПРЕДУСМОТРЕННОЙ СООТВЕТСТВУЮЩЕЙ ПРОГРАММОЙ СТРАХОВАНИЯ ВЫКУПНОЙ СУММЫ ПРОИЗВОДИТСЯ СОГЛАСНО ТАБЛИЦЕ ВЫКУПНЫХ СУММ  (ПРИЛОЖЕНИЕ № 1).' text,
  '*' prog
  from dual
  where :BRIEF_PRODUCT not in 'TERM'
  union all
  select
  'ЛЬГОТНЫЙ ПЕРИОД: '||:PA_DAYS||' ДНЕЙ.' text,
  '*' prog
  from dual
  union all
  select
  case :CUR_POLICY when 121 then 'РАСЧЕТ СТРАХОВЫХ СУММ И СТРАХОВЫХ ПРЕМИЙ ПРОИЗВЕДЕН С УЧЕТОМ ГАРАНТИРОВАННОЙ НОРМЫ ДОХОДНОСТИ - 3%. ' when 122 then 'РАСЧЕТ СТРАХОВЫХ СУММ И СТРАХОВЫХ ПРЕМИЙ ПРОИЗВЕДЕН С УЧЕТОМ ГАРАНТИРОВАННОЙ НОРМЫ ДОХОДНОСТИ - 4%. ' else 'РАСЧЕТ СТРАХОВЫХ СУММ И СТРАХОВЫХ ПРЕМИЙ ПРОИЗВЕДЕН С УЧЕТОМ ГАРАНТИРОВАННОЙ НОРМЫ ДОХОДНОСТИ - 3%. ' end as text,
  '*' prog
  from dual
  union all
  select
  'ДАТА ОКОНЧАНИЯ ПЕРИОДА ОЦЕНКИ СТРАХОВОГО РИСКА: ' || :WAITING_PERIOD_END_DATE || '.' text,
  '*' prog
  from dual
) 
 where prog like '%'||:BRIEF_PRODUCT||'%'
    or prog like '%*%']]>
      </select>
      <group name="G_text">
        <dataItem name="text" datatype="vchar2" columnOrder="13" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Text">
          <dataDescriptor expression="rownum || text"
           descriptiveExpression="TEXT" order="1" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_uslov_add">
      <select>
      <![CDATA[
select
  CASE WHEN :BRIEF_PRODUCT not in 'TERM' THEN '9. '
  	ELSE '8. '
	END || 'УЧИТЫВАЯ СВЕДЕНИЯ, СОДЕРЖАЩИЕСЯ В ЗАЯВЛЕНИИ НА СТРАХОВАНИЕ № '||:P_NOTICE||', ДОПОЛНИТЕЛЬНО К СОБЫТИЯМ УКАЗАННЫМ В П.4 "ПОЛИСНЫХ УСЛОВИЙ" '||upper(TRIM(:addendum_note)) text2
  from dual
where TRIM(:addendum_note) <> 'X'
]]>
      </select>
      <group name="G_text_add">
        <dataItem name="text2" datatype="vchar2" columnOrder="13" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Text 2">
          <dataDescriptor expression="rownum || text"
           descriptiveExpression="TEXT2" order="1" width="4000"/>
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
 and plt.brief in ('OPTIONAL','MANDATORY')
 and pl.t_lob_line_id = tll.t_lob_line_id
 and tl.t_lob_id = tll.t_lob_id
 and ig.t_insurance_group_id = tll.insurance_group_id
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
 and ig.brief = 'Acc'
 and plo.id not in (22603,32005,44179,22629,27622,27907,27624,28063,28065,28336,32005,43607,43609,44103,44131,44177,57134,57138,57738,57802,57871,57925,58264,28200,148357,148290,148315,148369,148375,148303,148308,148326,148334,148348,148353,148367,148376,148304,148309,148324,148333) -- согласовано с Д.Ивановым! добавлено 32005,28200 Веселуха
]]>
      </select>
      <group name="G_dop_summ_ns">
      </group>
    </dataSource>
    <dataSource name="RESERVE_ROW_PRIL">
      <select>
      <![CDATA[select count(1) RESERVE_ROW_PRIL
   from ven_policy_cash_surr p, ven_policy_cash_surr_d d, ins.t_lob_line lb
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :P_POLICY_ID
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
  WHERE a.p_policy_id = :P_POLICY_ID
    AND a.as_asset_id = pc.as_asset_id
    AND pc.t_prod_line_option_id = opt.id
    AND opt.product_line_id = pl.id
    AND pl.t_lob_line_id = lb.t_lob_line_id
    AND lb.brief = 'PEPR_INVEST_RESERVE') ir
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :P_POLICY_ID
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
	<dataSource name="Q_3">
      <select>
      <![CDATA[select 
nvl(ent.obj_name('CONTACT',b.contact_id),'X') as beneficiary,
nvl(to_char(pkg_contact.get_birth_date(b.contact_id),'dd.mm.yyyy'),'X') as ben_birth,
--nvl(pkg_contact.get_rel_description(su.assured_contact_id,b.contact_id),'X') as ben_rel,
nvl(ct.relationship_dsc,'X') ben_rel,
decode(b.value,null,'X',pkg_rep_utils.to_money_sep(b.value) || ' ' || decode(pth.brief,'percent','%','absol',f.brief)) as ben_part
from 
ven_as_asset a,
ven_as_assured su , 
ven_as_beneficiary b,
CN_CONTACT_REL cr,
t_contact_rel_type ct,
t_path_type   pth,
fund f,
(select :P_POLICY_ID id from dual) dd
where a.p_policy_id(+) = dd.id
 and b.as_asset_id(+) = a.as_asset_id
 and su.as_assured_id(+) = a.as_asset_id
 and pth.t_path_type_id (+) = b.value_type_id
 and f.fund_id (+) = b.t_currency_id
 and b.cn_contact_rel_id = cr.id(+)
 and cr.relationship_type = ct.id(+)]]>
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
v.INS_YEAR_FORMULA as year_number,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end,
pkg_rep_utils.to_money_sep(v.value) as ransom
from
 (select d.*, MONTHS_BETWEEN(d.insurance_year_date,ph.start_date) / 12 + 1 INS_YEAR_FORMULA
  from ven_policy_cash_surr p, ven_policy_cash_surr_d d, ins.p_pol_header ph
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :P_POLICY_ID
  AND p.pol_header_id = ph.policy_header_id
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
v.INS_YEAR_FORMULA as year_number,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end,
pkg_rep_utils.to_money_sep(v.value) as ransom
from
 (select d.*, MONTHS_BETWEEN(d.insurance_year_date,ph.start_date) / 12 + 1 INS_YEAR_FORMULA
  from ven_policy_cash_surr p, ven_policy_cash_surr_d d, ins.p_pol_header ph
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :P_POLICY_ID
  AND p.pol_header_id = ph.policy_header_id
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
v.INS_YEAR_FORMULA as year_number,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end,
pkg_rep_utils.to_money_sep(v.value) as ransom
from
 (select d.*, MONTHS_BETWEEN(d.insurance_year_date,ph.start_date) / 12 + 1 INS_YEAR_FORMULA
  from ven_policy_cash_surr p, ven_policy_cash_surr_d d, ins.p_pol_header ph
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :P_POLICY_ID
  AND p.pol_header_id = ph.policy_header_id
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
v.INS_YEAR_FORMULA as year_number,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end,
pkg_rep_utils.to_money_sep(v.value) as ransom
from
 (select d.*, MONTHS_BETWEEN(d.insurance_year_date,ph.start_date) / 12 + 1 INS_YEAR_FORMULA
  from ven_policy_cash_surr p, ven_policy_cash_surr_d d, ins.p_pol_header ph
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :P_POLICY_ID
  AND p.pol_header_id = ph.policy_header_id
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
v.INS_YEAR_FORMULA as year_number_i,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start_i,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end_i,
pkg_rep_utils.to_money_sep(v.value) as ransom_i
from
 (select d.*, MONTHS_BETWEEN(d.insurance_year_date,ph.start_date) / 12 + 1 INS_YEAR_FORMULA
  from ven_policy_cash_surr p, ven_policy_cash_surr_d d, ins.p_pol_header ph
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :P_POLICY_ID
  AND p.pol_header_id = ph.policy_header_id
  and p.T_LOB_LINE_ID = (select distinct T_LOB_LINE_ID from ven_t_product_line prl, ven_t_product_line_type prt
  where  prl.product_line_type_id = prt.product_line_type_id
  and p.T_LOB_LINE_ID = prl.T_LOB_LINE_ID
  AND prl.t_lob_line_id NOT IN (SELECT ll.t_lob_line_id
                              FROM ins.t_lob_line ll
                              WHERE ll.brief = 'PEPR_INVEST_RESERVE'
                              )
  and prl.visible_flag = 1
  and prt.brief in ('OPTIONAL','MANDATORY'))
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
v.INS_YEAR_FORMULA as year_number_i,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start_i,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end_i,
pkg_rep_utils.to_money_sep(v.value) as ransom_i
from
 (select d.*, MONTHS_BETWEEN(d.insurance_year_date,ph.start_date) / 12 + 1 INS_YEAR_FORMULA
  from ven_policy_cash_surr p, ven_policy_cash_surr_d d, ins.p_pol_header ph
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :P_POLICY_ID
  AND p.pol_header_id = ph.policy_header_id
  and p.T_LOB_LINE_ID = (select distinct T_LOB_LINE_ID from ven_t_product_line prl, ven_t_product_line_type prt
  where  prl.product_line_type_id = prt.product_line_type_id
  and p.T_LOB_LINE_ID = prl.T_LOB_LINE_ID
  AND prl.t_lob_line_id NOT IN (SELECT ll.t_lob_line_id
                              FROM ins.t_lob_line ll
                              WHERE ll.brief = 'PEPR_INVEST_RESERVE'
                              )
  and prl.visible_flag = 1
  and prt.brief in ('OPTIONAL','MANDATORY'))
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
v.INS_YEAR_FORMULA as year_number_i,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start_i,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end_i,
pkg_rep_utils.to_money_sep(v.value) as ransom_i
from
 (select d.*, MONTHS_BETWEEN(d.insurance_year_date,ph.start_date) / 12 + 1 INS_YEAR_FORMULA
  from ven_policy_cash_surr p, ven_policy_cash_surr_d d, ins.p_pol_header ph
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :P_POLICY_ID
  AND p.pol_header_id = ph.policy_header_id
  and p.T_LOB_LINE_ID = (select distinct T_LOB_LINE_ID from ven_t_product_line prl, ven_t_product_line_type prt
  where  prl.product_line_type_id = prt.product_line_type_id
  and p.T_LOB_LINE_ID = prl.T_LOB_LINE_ID
  AND prl.t_lob_line_id NOT IN (SELECT ll.t_lob_line_id
                              FROM ins.t_lob_line ll
                              WHERE ll.brief = 'PEPR_INVEST_RESERVE'
                              )
  and prl.visible_flag = 1
  and prt.brief in ('OPTIONAL','MANDATORY'))
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
v.INS_YEAR_FORMULA as year_number_i,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start_i,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end_i,
pkg_rep_utils.to_money_sep(v.value) as ransom_i
from
 (select d.*, MONTHS_BETWEEN(d.insurance_year_date,ph.start_date) / 12 + 1 INS_YEAR_FORMULA
  from ven_policy_cash_surr p, ven_policy_cash_surr_d d, ins.p_pol_header ph
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :P_POLICY_ID
  AND p.pol_header_id = ph.policy_header_id
  and p.T_LOB_LINE_ID = (select distinct T_LOB_LINE_ID from ven_t_product_line prl, ven_t_product_line_type prt
  where  prl.product_line_type_id = prt.product_line_type_id
  and p.T_LOB_LINE_ID = prl.T_LOB_LINE_ID
  AND prl.t_lob_line_id NOT IN (SELECT ll.t_lob_line_id
                              FROM ins.t_lob_line ll
                              WHERE ll.brief = 'PEPR_INVEST_RESERVE'
                              )
  and prl.visible_flag = 1
  and prt.brief in ('OPTIONAL','MANDATORY'))
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
v_amount ins.pkg_payment.t_amount;
v_amount_p NUMBER := 0;
v_amount_paid NUMBER := 0;
v_amount_t NUMBER := 0;
v_amount_to_pay NUMBER := 0;
begin

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
where pp.policy_id = :P_POLICY_ID
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
    where pp.policy_id = :P_POLICY_ID
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
where pp.policy_id = :P_POLICY_ID
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
             and plt.brief in ('OPTIONAL','MANDATORY')
             and (trunc(pc.end_date) - trunc(pc.start_date)) between 365 and 366
             and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
             order by plo.description) t ) 
    LOOP
        buf:= buf || rec.val;
    END LOOP;
    buf := '(' || rtrim(buf,';') || ')';
  :P_DOP_PROGR := '';

begin
 select a.as_asset_id
 into :asset_id
 from as_asset a 
 where a.p_policy_id = :P_POLICY_ID
 	   and rownum = 1;  
 exception
    when no_data_found then :asset_id := 0;   
 end; 

begin
select p.pol_header_id, case p.version_num when 1 then 2 else p.version_num end
into :pol_head_id, :ver_num
from p_policy p
where p.policy_id = :P_POLICY_ID;
exception
   when no_data_found then :pol_head_id := 0; :ver_num := 0;
end; 

begin
select ph.fund_id
into :ff
from p_pol_header ph
where ph.policy_header_id = :pol_head_id;
exception
   when no_data_found then :ff := 122;
end;

begin
select case when nvl(a.fee2,0) > nvl(d.fee1,0) then 1 else 0 end,
       d.fee1,
	   LTRIM(TO_CHAR(a.fee2 - d.fee1, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) ||' '|| case :ff when 122 then 'руб.' when 5 then 'евро' when 121 then 'дол' else '' end || '('||pkg_utils.money2speech(a.fee2 - d.fee1,:ff)||')',
	   case when p.waiting_period_end_date > c.active_date then to_char(trunc(c.active_date),'dd.mm.yyyy')
	   		else to_char(trunc(p.waiting_period_end_date),'dd.mm.yyyy') end
	   --to_char(trunc(p.waiting_period_end_date),'dd.mm.yyyy'),
	   --to_char(trunc(c.active_date),'dd.mm.yyyy')
into :flg, :v_fee1, :v_fee2, :PRINT_DATE_VIPL--, :v_ad
from p_policy p,
     (select sum(nvl(ass.fee,0)) fee2
           from as_asset ass 
           where ass.p_policy_id = :P_POLICY_ID) a,
     (select trunc(max(ds.change_date)) + 30 active_date
        from doc_status ds
        where ds.doc_status_ref_id = 19
              and ds.document_id = :P_POLICY_ID) c,
    (select sum(nvl(a.fee,0)) fee1
                from p_policy pp,
                     as_asset a
                where pp.pol_header_id = :pol_head_id
                      and pp.version_num = :ver_num - 1
                      and a.p_policy_id = pp.policy_id) d
where p.policy_id = :P_POLICY_ID;
exception
    when no_data_found then :flg:=0; :v_fee1:=0; :v_fee2:=''; :PRINT_DATE_VIPL:=to_char(sysdate,'dd.mm.yyyy'); --:v_ad:=to_char(sysdate,'dd.mm.yyyy');
 end;
  
begin 
select nvl(ame.addendum_note,'X')
into :addendum_note
from AS_ASSURED_DOCUM  asd,
     ASSURED_DOCUM_TYPE asdt,
     VEN_AS_ASSURED_UNDERWR ame,
     VEN_AS_ASSURED vass,
     ven_p_policy vpp,
     VEN_CONTACT vc,
     VEN_CN_PERSON cnp,
     VEN_T_PAYMENT_TERMS vt,
     VEN_T_PROFESSION vtp
where vass.AS_ASSURED_ID = asd.AS_ASSURED_ID(+) 
  and vass.P_POLICY_ID = vpp.POLICY_ID(+)
  and vass.ASSURED_CONTACT_ID = vc.CONTACT_ID(+)
  and vass.ASSURED_CONTACT_ID = cnp.CONTACT_ID(+)
  and vass.T_PROFESSION_ID = vtp.ID(+)
  and vass.AS_ASSURED_ID = ame.AS_ASSURED_ID(+)
  and asd.ASSURED_DOCUM_TYPE_ID = asdt.ASSURED_DOCUM_TYPE_ID(+)
  and nvl(asdt.BRIEF,' ') in('MEDICAL EXAM','MEDICAL_FORM','WORK_FORM','FINANCE_FORM','HOBBY_FORM',' ')
  and vpp.PAYMENT_TERM_ID = vt.ID(+)
  and vass.AS_ASSURED_ID= :asset_id
and rownum = 1;
exception
    when no_data_found then :addendum_note := 'X';   
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
    CASE WHEN ak.brief IN ('END_2','CHI_2','PEPR_2','TERM_2') THEN
          substr(upper(ak.brief),1,length(upper(ak.brief)) - length(substr(upper(ak.brief),-2)))
         ELSE ak.brief
    END brief,
	--ak.brief,
    decode(pp.pol_ser,null,pp.pol_num,pp.pol_ser || '-' || pp.pol_num),
    --pp.notice_ser||pp.notice_num,
	case when length(pp.pol_num)>6 then substr(decode(pp.pol_ser,null,pp.pol_num,pp.pol_ser || '-' || pp.pol_num),4,6) else pp.pol_num end,
    case when length(pp.notice_ser||pp.notice_num)>9 then substr(pp.notice_ser||pp.notice_num,4,6) else pp.notice_num end,
    ph.fund_id,
       -- Продукт
    --upper(ent.obj_name('T_PRODUCT',ph.product_id)),
	CASE WHEN ak.brief IN ('END_2','CHI_2','PEPR_2','TERM_2') THEN
           substr(upper(ent.obj_name('T_PRODUCT',ph.product_id)),1,length(upper(ent.obj_name('T_PRODUCT',ph.product_id))) - length(substr(upper(ent.obj_name('T_PRODUCT',ph.product_id)),-2)))
      ELSE upper(ent.obj_name('T_PRODUCT',ph.product_id))
    END,
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
	--case lower(vt.DESCRIPTION) when 'ежемесячно' then 30 else 45 end,
	trim(to_char(lper.period_value)) period_value,
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
           vf.brief) kod_val_up,
	to_char(round(extract(year from pp.end_date)-extract(year from ph.start_date),2))||' лет  с "'||to_char(ph.start_date,'dd')||'" '||case extract(month from ph.start_date) when 1 then 'января' 
                                                                 when 2 then 'февраля' 
                                                                 when 3 then 'марта'
                                                                 when 4 then 'апреля'
                                                                 when 5 then 'мая'
                                                                 when 6 then 'июня'
                                                                 when 7 then 'июля'
                                                                 when 8 then 'августа'
                                                                 when 9 then 'сентября'
                                                                 when 10 then 'октября'
                                                                 when 11 then 'ноября'
                                                                 when 12 then 'декабря' else '' end||' '||to_char(ph.start_date,'yyyy')||' г. по "'||to_char(pp.end_date,'dd')||'" '||case extract(month from pp.end_date) when 1 then 'января' 
                                                                 when 2 then 'февраля' 
                                                                 when 3 then 'марта'
                                                                 when 4 then 'апреля'
                                                                 when 5 then 'мая'
                                                                 when 6 then 'июня'
                                                                 when 7 then 'июля'
                                                                 when 8 then 'августа'
                                                                 when 9 then 'сентября'
                                                                 when 10 then 'октября'
                                                                 when 11 then 'ноября'
                                                                 when 12 then 'декабря' else '' end||' '||to_char(pp.end_date,'yyyy')||' г.' y,
	pkg_renlife_utils.ret_ser_policy(pp.policy_id)
    into :BRIEF_PRODUCT,:policy_number,:POL_NUM,:P_NOTICE,:CUR_POLICY,:PROGRAMMA,:P_SYSDATE,:TYPE_CONT,:POL_HOLDER,:PH_BIRTH,:PH_DOC,:POL_ASS,:PA_BIRTH,:PA_DOC, :PA_PERIODICH, :PA_DAYS,:PA_PER, :WAITING_PERIOD_END_DATE, :PA_ROW_PRIL, :PA_KOD_VAL,:PA_KOD_VAL_UP, :Y, :seria
    from t_product ak, ven_p_policy pp, t_period lper, ven_p_pol_header ph, ven_as_asset a , ven_as_assured s, contact cont, VEN_T_PAYMENT_TERMS vt, VEN_FUND vf,
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
	 and pp.pol_privilege_period_id = lper.id(+)
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
       '"'||upper(plo.description)||'"'
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
        ven_t_prod_line_option plo,
		t_product_line pl
  where pp.policy_id = :P_POLICY_ID
   and ass.p_policy_id = pp.policy_id
   --and (pc.decline_reason_id is null or pc.decline_date is null)
and pc.decline_date is null
   and pc.as_asset_id = ass.as_asset_id
   and plo.id = pc.t_prod_line_option_id
   and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
   AND plo.product_line_id = pl.id
   AND pl.t_lob_line_id NOT IN (SELECT ll.t_lob_line_id
                              FROM ins.t_lob_line ll
                              WHERE ll.brief = 'PEPR_INVEST_RESERVE'
                              );
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
            ven_t_prod_line_option plo,
			status_hist h
    where pp.policy_id = :P_POLICY_ID
     and ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
	 and h.status_hist_id = pc.status_hist_id
	 and h.name <> 'Удален'
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
    decode(nvl(pt.number_of_payments,0),0,'X',1,to_char(pps.due_date,'dd.mm')||' '||'каждого последующего года срока страхования',
                      12,to_char(add_months(pps.due_date,1),'dd') ||' '||'числа каждого месяца срока страхования',                                              
                      2,to_char(add_months(pps.due_date,6),'dd.mm') || ', ' ||to_char(pps.due_date,'dd.mm')||' '||'каждого последующего года срока страхования',
                                        4,to_char(add_months(pps.due_date,3),'dd.mm') || ', ' ||to_char(add_months(pps.due_date,6),'dd.mm') || ', ' ||
                                        to_char(add_months(pps.due_date,9),'dd.mm') || ', ' ||to_char(pps.due_date,'dd.mm')||' '||'каждого последующего года срока страхования')
    into :FIRST_PAY, :NEXT_PAYS
    from v_policy_payment_schedule pps, ven_ac_payment ap, ven_p_policy pp, ven_t_payment_terms pt
    where pps.pol_header_id = pp.pol_header_id 
    and pps.document_id = ap.payment_id
  	and pp.policy_id = :P_POLICY_ID
  	and pp.payment_term_id = pt.id
	and ap.payment_number = (
    select min(ac.payment_number)
    from doc_doc dd,
         ven_ac_payment ac
    where dd.child_id = ac.payment_id
          and dd.parent_id IN (SELECT pol.policy_id FROM ins.p_policy pol WHERE pol.pol_header_id = pp.pol_header_id)
          and ac.doc_templ_id = (select tmpl.doc_templ_id from ins.doc_templ tmpl where tmpl.brief = 'PAYMENT'
          and doc.get_doc_status_brief(ac.payment_id) != 'ANNULATED')
    );
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
 and plt.brief in ('OPTIONAL','MANDATORY')
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
 AND pl.t_lob_line_id NOT IN (SELECT ll.t_lob_line_id
                              FROM ins.t_lob_line ll
                              WHERE ll.brief = 'PEPR_INVEST_RESERVE'
                              );
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
 and plt.brief in ('OPTIONAL','MANDATORY')
 and pl.t_lob_line_id = tll.t_lob_line_id
 and tl.t_lob_id = tll.t_lob_id
 and ig.t_insurance_group_id = tll.insurance_group_id
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
 and ig.brief = 'Acc'
 and plo.id not in (22603,32005,44179,22629,27622,27907,27624,28063,28065,28336,32005,43607,43609,44103,44131,44177,57134,57138,57738,57802,57871,57925,58264,28200,148357,148290,148315,148369,148375,148303,148308,148326,148334,148348,148353,148367,148376,148304,148309,148324,148333) -- согласовано с Д.Ивановым! добавлено 32005,28200 Веселуха
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
		   								'Освобождение от уплаты дальнейших взносов рассчитанное по основной программе','Освобождение от уплаты страховых взносов',
									 'Освобождение от уплаты взносов рассчитанное по основной программе','Освобождение от уплаты страховых взносов',
              (plo.description)) || '"' as description, null
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
            where pp.policy_id = :P_POLICY_ID
             and ass.p_policy_id = pp.policy_id
             and pc.as_asset_id = ass.as_asset_id
			 --and (pc.decline_reason_id is null or pc.decline_date is null)
             and pc.decline_date is null
             and plo.id = pc.t_prod_line_option_id
             and plo.product_line_id = pl.id
             and pl.product_line_type_id = plt.product_line_type_id
             and plt.brief in ('OPTIONAL','MANDATORY')
             and trunc(pc.start_date) = trunc(:start_date)
             and trunc(pc.end_date) = trunc(:end_date)
             and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
             and pl.t_lob_line_id = tll.t_lob_line_id
             and tl.t_lob_id = tll.t_lob_id
             and ig.t_insurance_group_id = tll.insurance_group_id
             and (ig.brief <> 'Acc' or plo.id in (22603,32005,44179,22629,27622,27907,27624,28063,28065,28336,32005,43607,43609,44103,44131,44177,57134,57138,57738,57802,57871,57925,58264,28200,148357,148290,148315,148369,148375,148303,148308,148326,148334,148348,148353,148367,148376,148304,148309,148324,148333)) -- согласовано с Д.Ивановым! добавлено 32005,28200 Веселуха
union
select decode(count(*),0,'','Страхование от несчастных случаев и болезней'),
       count(*) nm
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
where pp.policy_id = :P_POLICY_ID
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pc.decline_date is null
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief in ('OPTIONAL','MANDATORY')
 and trunc(pc.start_date) = trunc(:start_date)
 and trunc(pc.end_date) = trunc(:end_date)
 and pl.t_lob_line_id = tll.t_lob_line_id
 and tl.t_lob_id = tll.t_lob_id
 and ig.t_insurance_group_id = tll.insurance_group_id
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
 and ig.brief = 'Acc'
 and plo.id not in (22603,32005,44179,22629,27622,27907,27624,28063,28065,28336,32005,43607,43609,44103,44131,44177,57134,57138,57738,57802,57871,57925,58264,28200,148357,148290,148315,148369,148375,148303,148308,148326,148334,148348,148353,148367,148376,148304,148309,148324,148333) -- согласовано с Д.Ивановым! добавлено 32005,28200 Веселуха
 ) t ) 
    LOOP
        buf:= buf || rec.val;
    END LOOP;
    buf := '(' || rtrim(buf,';') || ')';
  end; else begin 
    :P_OSN_PROGR := 1;
      -- Проверяем входит ли в срок страхования Основная программа
    select '(основная программа:"'||plo.description||')'
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
 str1 varchar2(4000);
 str2 varchar2(4000);
 str3 varchar2(4000);
 str varchar2(4000);
 xx number := :dd;
begin
 n:=to_number(to_char(d,'hh24'));
 if n in (1,21) then 
   buf := 'час ';
 else if n in (2,3,4,22,23,23) then 
        buf := 'часа ';
      else buf := 'часов ';
      end if;
  end if;

str1 := 'По страховому риску Смерть ЛП: 00:00 часов 4-го дня, следующего за датой оплаты страховой премии (первого страхового взноса) '||to_char(d,'dd.mm.yyyy')||'.'||' По страховым рискам Дожитие, ПДСОЗ: 00:00 часов 1-го дня, следующего за датой оплаты страховой премии (первого страхового взноса) '||to_char(d,'dd.mm.yyyy');
str2 := 'По страховым рискам Смерть НС, Инвалидность НС, Смерть ЛП, Инвалидность ЛП: 00:00 часов 4-го дня, следующего за датой оплаты страховой премии (первого страхового взноса) '||to_char(d,'dd.mm.yyyy')||'. По страховым рискам Телесные повреждения, ВНТ НС, Госпитализация НС, Госпитализация НСиБ, ХВ НС, ХВ НСиБ, программе страхования Расширенная госпитализация: 00:00 часов 16-го дня, следующего за датой оплаты страховой премии (первого страхового взноса) '||to_char(d,'dd.mm.yyyy');
str3 := 'По страховому риску Смерть ЛП: 00:00 часов 4-го дня, следующего за датой оплаты страховой премии (первого страхового взноса) '||to_char(d,'dd.mm.yyyy')||'. По страховым рискам Дожитие: 00:00 часов 1-го дня, следующего за датой оплаты страховой премии (первого страхового взноса) '||to_char(d,'dd.mm.yyyy');
    
if xx in (22) then 
   str := str1;
   else if xx in (32) then 
        str := str2;
   else str := str3;
   end if;
end if;

--return(str);
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

<rw:foreach id="G_RESERVE_ROW_PRIL" src="G_RESERVE_ROW_PRIL">
<rw:getValue id="RESERVE_ROW_PRIL" src="RESERVE_ROW_PRIL"/>
<% RESERVE_PRIL = Double.valueOf(RESERVE_ROW_PRIL).doubleValue();%>
</rw:foreach>

<div class=Section1>

<p class=MsoNormal align=right style='text-align:right'><b style='mso-bidi-font-weight:
normal'><span style='font-size:8.0pt;mso-ansi-language:RU'>Дополнительное
соглашение №1<o:p></o:p></span></b></p>

<p class=MsoNormal align=right style='text-align:right'><b style='mso-bidi-font-weight:
normal'><span style='font-size:8.0pt;mso-ansi-language:RU'>к Полису страхования
жизни № <rw:field id="" src="SERIA"/> <rw:field id="" src="P_NOTICE"/><o:p></o:p></span></b></p>

<p class=MsoNormal align=right style='text-align:right'><span style='font-size:
6.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal align=right style='text-align:right;text-indent:18.0pt'><span
style='font-size:7.0pt;letter-spacing:-.1pt;mso-ansi-language:RU'>ООО "СК
"Ренессанс Жизнь", именуемое в дальнейшем "Страховщик", в лице Управляющего
Директора Киселева О.М., действующего на основании Доверенности № 2011/01 от
01.01.2011 г., с одной стороны, <o:p></o:p></span></p>

<p class=MsoNormal align=right style='text-align:right;text-indent:18.0pt'><span
style='font-size:7.0pt;letter-spacing:-.1pt;mso-ansi-language:RU'>и <rw:field id="" src="POL_HOLDER"/>,
 <rw:field id="" src="PH_DOC"/>, </span><o:p></o:p></span></p>

<p class=MsoNormal align=right style='text-align:right;text-indent:18.0pt'><span
style='font-size:7.0pt;letter-spacing:-.1pt;mso-ansi-language:RU'>именуемый (<span
class=SpellE>ая</span>)<span style='mso-spacerun:yes'>  </span>в дальнейшем
"Страхователь", с другой стороны, <o:p></o:p></span></p>

<p class=MsoNormal align=right style='text-align:right;text-indent:18.0pt'><span
style='font-size:7.0pt;letter-spacing:-.1pt;mso-ansi-language:RU'>заключили
настоящее Дополнительное Соглашение к Договору страхования № <rw:field id="" src="SERIA"/> <rw:field id="" src="P_NOTICE"/> <span
style='mso-spacerun:yes'> </span>о нижеследующем:<o:p></o:p></span></p>

<p class=MsoNormal align=right style='text-align:right'><span style='font-size:
7.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal align=right style='text-align:right'><span style='font-size:
7.0pt;mso-ansi-language:RU'>1. Стороны договорились изменить Полис страхования
жизни № <rw:field id="" src="SERIA"/> <rw:field id="" src="P_NOTICE"/> <o:p></o:p></span></p>

<p class=MsoNormal align=right style='text-align:right'><span style='font-size:
7.0pt;mso-ansi-language:RU'>и изложить его в следующей редакции: <o:p></o:p></span></p>


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
  style='font-size:18.0pt;color:#FF6600;mso-ansi-language:RU'>Полис (договор) страхования жизни № <rw:field id="" src="POLICY_NUMBER"/></span></b></p>
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
  style='font-size:8.0pt;mso-ansi-language:RU'><% if ((t_cont.equals("1")) || (t_cont.equals("3")) || (t_cont.equals("1030"))) { %>Ф.И.О.<% } else { %><% } %><o:p></o:p></span></b></p>
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
  style='font-size:8.0pt;mso-ansi-language:RU'><% if ((t_cont.equals("1")) || (t_cont.equals("3")) || (t_cont.equals("1030"))) { %>ДОКУМЕНТ<% } else { %><% } %><o:p></o:p></span></b></p>
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
  color:#FF6600;mso-ansi-language:RU'>4. ПРОГРАММЫ СТРАХОВАНИЯ (СТРАХОВЫЕ РИСКИ). СТРАХОВЫЕ СУММЫ. СТРАХОВАЯ ПРЕМИЯ (ВЗНОС)</span></b><b
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
  RU'>Страховая премия (страховой взнос), <rw:field id="" src="PA_KOD_VAL"/></span></i></p>
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
  style='font-size:8.0pt;mso-ansi-language:RU'>ОСНОВНАЯ ПРОГРАММА: </span></b><span
  style='font-size:8.0pt;mso-ansi-language:RU;mso-bidi-font-weight:bold'>
  <rw:field id="" src="MAIN_COVER"/><!--rw:getValue id="j_programma" src="programma"/>
  < % if (j_programma.equals("ГАРМОНИЯ ЖИЗНИ")) { % > (ПУНКТ 3.1. ОБЩИХ УСЛОВИЙ СТРАХОВАНИЯ ПО
  ИНДИВИДУАЛЬНОМУ СТРАХОВАНИЮ И СТРАХОВАНИЮ ОТ НЕСЧАСТНЫХ СЛУЧАЕВ (ДАЛЕЕ -
  ОБЩИХ УСЛОВИЙ СТРАХОВАНИЯ)< % } % --></span><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p><b>*</b></span></b></p>
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
 <% if (!j_has_dop.equals("0")) { %>
 <tr style='mso-yfti-irow:27'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>ДОПОЛНИТЕЛЬНЫЕ ПРОГРАММЫ (СТРАХОВЫЕ РИСКИ):<o:p></o:p><b>*</b></span></b></p>
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
  <td width=455 colspan=2 valign=top style='width:341.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-left:12.6pt;text-indent:-12.6pt'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><span style='mso-spacerun:yes'> 
  </span>* &quot;СТРАХОВАНИЕ ОТ НЕСЧАСТНЫХ СЛУЧАЕВ И БОЛЕЗНЕЙ&quot;<!-- (ПУНКТ 1 ПРИЛОЖЕНИЯ №1
  К ОБЩИМ УСЛОВИЯМ СТРАХОВАНИЯ)-->, <i style='mso-bidi-font-style:normal'><span
  style='mso-spacerun:yes'> </span>включая следующие риски:<o:p></o:p></i></span></p>
  </td>
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
 <tr style='mso-yfti-irow:36'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;border:none;
  mso-border-bottom-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:82.2pt;border:none;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
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
  normal'><span style='font-size:8.0pt;mso-ansi-language:RU'>ИТОГО <a
  name="ns_ins"></a><span style='mso-spacerun:yes'> </span>СТРАХОВАЯ ПРЕМИЯ (ВЗНОС)<span
  style='mso-spacerun:yes'>   </span>ПО ДОГОВОРУ:
  <i style='mso-bidi-font-style:normal'>(уплачивается <rw:field id="" src="PA_PERIODICH"/>)</i>:<o:p></o:p></span></b></p>
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
<rw:getValue id="PER" src="PA_PER"/>
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
  RU'>уплачивается <a name="charge_period"><% if (PER.equals("1")) {%> <rw:field id="" src="PA_PERIODICH"/> <%} else {%> раз в год <%} %> </a></span></i></b><b
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
  
  <rw:getValue id="J_EXIST_DOP_RES" src="P_EXIST_DOP_RESERVE"/><% if ( !J_EXIST_DOP_RES.equals("0") ) { %>
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
  <td width=110 valign=top style='width:82.2pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ДОПОЛНИТЕЛЬНЫЕ ПРОГРАММЫ<o:p></o:p></span></b></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:dashed windowtext 1.0pt;border-left:
  dashed windowtext 1.0pt;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt'>Страховая
  сумма, <rw:field id="" src="PA_KOD_VAL"/><o:p></o:p></span></i></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:dashed windowtext 1.0pt;border-left:
  dashed windowtext 1.0pt;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt'>Страховая премия, <rw:field id="" src="PA_KOD_VAL"/><o:p></o:p></span></i></p>
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
  <td width=110 valign=top style='width:82.2pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <rw:foreach id="G_DOP_SUMM_RESERVE" src="G_DOP_SUMM_RESERVE">
 <tr style='mso-yfti-irow:7'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p><rw:field id="" src="dop_progr_r"/> от <rw:field id="" src="start_date_r"/></o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:dashed windowtext 1.0pt;border-left:
  dashed windowtext 1.0pt;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>
    <rw:getValue id="j_need_x_11" src="need_x_r"/><% if (j_need_x_11.equals("1")) { %>X<% } else { %><rw:field id="" src="dop_summ_r"/><% } %>
  <o:p></o:p></span></b></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:dashed windowtext 1.0pt;border-left:
  dashed windowtext 1.0pt;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
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
  <td width=110 valign=top style='width:82.2pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 </rw:foreach>

<tr style='mso-yfti-irow:8'>
  <td width=598 colspan=4 valign=top style='width:448.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:left'><b><span style='font-size:8.0pt'>ИТОГО СТРАХОВАЯ ПРЕМИЯ ПО ПРОГРАММАМ "Инвест-резерв" (оплачено):<o:p></o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:105.0pt;border-top:dashed windowtext 1.0pt;border-left:
  dashed windowtext 1.0pt;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><rw:field id="" src="PAID_RESERVE"/><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8'>
  <td width=598 colspan=4 valign=top style='width:448.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:left'><b><span style='font-size:8.0pt'>ИТОГО СТРАХОВАЯ ПРЕМИЯ ПО ПРОГРАММАМ "Инвест-резерв" (к оплате):<o:p></o:p></span></b></p>
  </td>
  <td width=110 valign=top style='width:105.0pt;border-top:dashed windowtext 1.0pt;border-left:
  dashed windowtext 1.0pt;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><rw:field id="" src="TO_PAY_RESERVE"/><o:p></o:p></span></b></p>
  </td>
 </tr>
 
 <%}%>

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
<p class=MsoNormal><span style='mso-ansi-language:RU'>*</span><b
style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
RU'> Страховыми случаями по договору страхования являются события, перечисленные
в настоящем Разделе, за исключением событий, <o:p></o:p></span></b></p>
<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='font-size:8.0pt;mso-ansi-language:RU'>перечисленных в Разделе 4 Полисных
условий<o:p></o:p></span></b></p>

<span lang=EN-US style='font-size:12.0pt;font-family:"Times New Roman";
mso-fareast-font-family:"Times New Roman";mso-ansi-language:EN-US;mso-fareast-language:
EN-US;mso-bidi-language:AR-SA'><br clear=all style='mso-special-character:line-break;
page-break-before:always'>
</span>

<p class=MsoNormal><span lang=EN-US><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=708
 style='width:531.0pt;mar-gin-left:-48.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
<tr style='mso-yfti-irow:8;'>
  <td width=467 colspan=9 valign=top style='width:350.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600;mso-ansi-language:RU'>5. УСЛОВИЯ И СРОКИ УПЛАТЫ СТРАХОВОЙ<span
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
  style='font-size:8.0pt;mso-ansi-language:RU'>ДАТА УПЛАТЫ СТРАХОВОЙ ПРЕМИИ (ПЕРВОГО СТРАХОВОГО ВЗНОСА):<o:p></o:p></span></b></p>
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
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><rw:field id="" src="NEXT_PAYS"/> <b
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

<br></br>  
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:2.0pt;'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600;mso-ansi-language:RU'>6. СРОК ДЕЙСТВИЯ ДОГОВОРА СТРАХОВАНИЯ. СРОК СТРАХОВАНИЯ</span></b><b
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
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:2.0pt;'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600;mso-ansi-language:RU'>СРОК ДЕЙСТВИЯ ДОГОВОРА СТРАХОВАНИЯ: <rw:field id="" src="Y"/></span></b><b
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
  style='font-size:8.0pt;mso-ansi-language:RU'>СРОК СТРАХОВАНИЯ:<o:p></o:p></span></b></p>
  </td>
  <td width=60 valign=top style='width:45.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.0pt'>
  <p class=MsoNormal style='tab-stops:center 17.1pt'><span style='font-size:
  8.0pt;mso-ansi-language:RU'><span style='mso-tab-count:1'></span></span></p>
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
  mso-ansi-language:RU'><span style='mso-spacerun:yes'></span><o:p></o:p></span></p>
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
  <% if (!j_has_dop.equals("0")) { %>
 
 <tr style='mso-yfti-irow:6;height:3.15pt;'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.15pt'>
  <p class=MsoNormal style='margin-top:12.0pt;text-align:justify'><a
  name="print_days"><b style='mso-bidi-font-weight:normal'><i><span
  style='font-size:8.0pt;mso-ansi-language:RU'>Если Страхователь за 30 (тридцать) календарных дней до дня окончания 
  срока страхования по указанным дополнительным программам не направит письменное заявление Страховщику о намерении
  исключить какую-либо из указанных программ или рисков из договора страхования или внести в них изменения, срок страхования по указанным
  дополнительным программам (страховым рискам) продлевается до даты наступления очередной страховой
  годовщины. Страховщик оставляет за собой право в страховую годовщину изменить размер страховой премии (взноса)
   по указанным программам (рискам) в случае изменения страховых тарифов Страховщика, предварительно уведомив об этом Страхователя.
  Страхователь, в случае отказа от продления срока страхования по дополнительным программам (рискам) на новых условиях, должен
  в течение 5-ти (пяти) дней с момента получения уведомления Страховщика сообщить об отказе от продления срока страхования по 
  дополнительным программам на новых условиях.
   </i></span></b></span><b
  style='mso-bidi-font-weight:normal'><i><span style='font-size:9.0pt;
  mso-bidi-font-size:12.0pt;mso-ansi-language:RU;mso-no-proof:yes'><o:p></o:p></span></i></b></p>
  </td> 
 </tr>
  <% } %>
 <tr style='mso-yfti-irow:6;height:3.15pt;'>
  <td width=203 colspan=4 valign=top style='width:152.5pt;padding:0cm 5.4pt 0cm 5.4pt'>
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
  <td width=1000 colspan=12 valign=top style='width:1000.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
<br></br>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600;mso-ansi-language:RU'>8. ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ</span></b><span
  style='font-size:9.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
 </tr>

 <tr style='mso-yfti-irow:21;page-break-inside:avoid;height:1.9pt'>
  <td width=1000 colspan=12 valign=top style='width:1000.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:1.9pt'>
  <p class=MsoNormal style='margin-left:5.4pt;text-indent:-5.4pt'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>

 
 <rw:foreach id="fi_dop_uslov" src="G_text">
 <tr style='mso-yfti-irow:22'>
  <td width=1000 colspan=12 valign=top style='width:1000.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-left:9.0pt;text-indent:-9.0pt'><span
  style='font-size:6.0pt;mso-ansi-language:RU'><rw:field id="" src="text"/></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:23;page-break-inside:avoid;height:1.0pt'>
  <td width=1000 colspan=12 valign=top style='width:1000.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:1.9pt'>
  <p class=MsoNormal style='margin-left:5.4pt;text-indent:-5.4pt'><span
  style='font-size:5.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
 
  <rw:foreach id="fi_add_uslov" src="G_text_add">
 <tr style='mso-yfti-irow:22'>
  <td width=1000 colspan=12 valign=top style='width:1000.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-left:9.0pt;text-indent:-9.0pt'><span
  style='font-size:6.0pt;mso-ansi-language:RU'><rw:field id="" src="text2"/></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:23;page-break-inside:avoid;height:1.0pt'>
  <td width=1000 colspan=12 valign=top style='width:1000.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:1.9pt'>
  <p class=MsoNormal style='margin-left:5.4pt;text-indent:-5.4pt'><span
  style='font-size:5.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
 
 <tr style='mso-yfti-irow:23;page-break-inside:avoid;height:1.0pt'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:1.9pt'>
  <p class=MsoNormal style='margin-left:5.4pt;text-indent:-5.4pt'><span
  style='font-size:5.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:23;page-break-inside:avoid;height:1.0pt'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:1.9pt'>
  <p class=MsoNormal style='margin-left:5.4pt;text-indent:-5.4pt'><span
  style='font-size:7.0pt;mso-ansi-language:RU'>Подписывая настоящий Полис, Страхователь 
  (Застрахованный) в соответствии c Федеральным законом от 27 июля 2006 г. № 152-ФЗ "О персональных данных"
  выражает(ют) Страховщику согласие на обработку своих персональных данных, содержащихся в документах, 
  передаваемых Страховщику в целях продвижения товаров, работ, услуг на рынке путем осуществления прямых контактов 
  с помощью средств связи, в том числе в целях обеспечения исполнения настоящего Полиса, а также выражает(ют) 
  Страховщику согласие на предоставление Выгодоприобретателю(ям)  информации по настоящему Полису,  об исполнении 
  Страховщиком и/или Страхователем (Застрахованным) обязательств по настоящему Полису, в том числе информацию об 
  оплате и размере страховой премии (страховых взносов), размере страховой суммы, о возникновении и урегулировании 
  претензий, наступлении/вероятности наступления страховых случаев, выплате страхового возмещения и другую имеющую 
  отношение к настоящему Полису информацию. 
Обработка персональных данных осуществляется посредством сбора, систематизации, накопления, хранения, уточнения 
(обновления, изменения), использования, распространения, передачу (в том числе трансграничную), обезличивания, 
блокирования, уничтожения персональных данных, как на бумажных, так и на электронных носителях. 
Настоящее согласие Страхователя (Застрахованного) действительно в течение срока действия настоящего Полиса и в 
течение 5 лет после окончания срока действия настоящего Полиса и может быть отозвано Страхователем (Застрахованным) 
в любой момент времени путем передачи Страховщику подписанного Страхователем (Застрахованным) письменного уведомления.</span></p>
  </td>
 </tr> 
 <tr style='mso-yfti-irow:23;page-break-inside:avoid;height:1.0pt'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:1.9pt'>
  <p class=MsoNormal style='margin-left:5.4pt;text-indent:-5.4pt'><span
  style='font-size:5.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr> 
 
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
  style='font-size:8.0pt;mso-ansi-language:RU'>К настоящему договору (Полису) прилагаются:<o:p></o:p></span></i></p>
  </td>
  <td width=444 colspan=9 valign=top style='width:333.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><%=format.format(NN++)%>. Приложение №1: "Полисные условия к договору
  страхования жизни по программам страхования жизни "Гармония жизни", "Семья", "Дети", "Будущее" от 01.04.2009 г.</span></i></p>
  </td>
 </tr>

 <tr style='mso-yfti-irow:36'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></p>
  </td>
  <td width=444 colspan=9 valign=top style='width:333.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><%=format.format(NN++)%>. Приложение №2: Заявление на страхование
  жизни №<span style='mso-spacerun:yes'>  </span><rw:field id="" src="SERIA"/> <rw:field id="" src="P_NOTICE"/></span></i></p>
  </td>
 </tr>
 
  <tr style='mso-yfti-irow:35'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'></span></i></p>
  </td>
  <td width=444 colspan=9 valign=top style='width:333.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><% if (!jProdBrief.equals("TERM") ) { %><%=format.format(NN++)%>. Приложение №3: Таблица выкупных сумм по
  основной программе<% } else { %>&nbsp;<% } %><o:p></o:p></span></i></p>
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
  style='font-size:8.0pt;mso-ansi-language:RU'><% if (j_inv.equals("1")) { %><%=format.format(NN++)%>. Приложение №4: Таблица выкупных сумм по
  дополнительной программе страхования "Инвест"<% } else { %><% } %><o:p><o:p/></span></i></p>
  </td>
 </tr>
</rw:foreach>

 <tr style='mso-yfti-irow:38'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=444 colspan=9 valign=top style='width:333.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right><span style='font-size:7.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 
 <tr style='mso-yfti-irow:23;page-break-inside:avoid;height:1.0pt'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:1.9pt'><p class=MsoNormal style='margin-left:5.4pt;text-indent:-5.4pt'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>2.  Изложить п.п. 1.12., 7.5. и 7.7. 
  "Полисных условий к договору страхования жизни по программам страхования жизни "Гармония жизни", "Семья", "Дети", 
  "Будущее" в следующей редакции: </span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:23;page-break-inside:avoid;height:1.0pt'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:1.9pt'><p class=MsoNormal style='margin-left:5.4pt;text-indent:-5.4pt'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>"1.12. Льготный период - период времени, равный 45 (сорока пяти) календарным 
  дням с указанной в договоре страхования даты оплаты очередного взноса, при оплате страховых взносов раз в квартал, 
  раз в полгода или раз в год, или период времени, равный 30 (тридцати) календарным дням, с указанной в договоре 
  страхования даты оплаты очередного взноса, при оплате страховых взносов раз в месяц, в течение которого при наступлении
   страхового случая и нарушении Страхователем обязанности по своевременной уплате страховых взносов существует 
   обязанность Страховщика произвести страховую выплату. Страховая выплата производится только при условии, что до 
   окончания льготного периода Страхователем будет оплачен просроченный страховой взнос.</span></p>
  </td>
 </tr>
 
<tr style='mso-yfti-irow:23;page-break-inside:avoid;height:1.0pt'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:1.9pt'><p class=MsoNormal style='margin-left:5.4pt;text-indent:-5.4pt'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>7.5. Страховая премия по договору страхования может быть уплачена Страхователем
  единовременно (разовым платежом) за весь срок страхования или в рассрочку страховыми взносами
  (раз в год, раз в полгода, раз в квартал либо раз в месяц). Ежемесячная форма оплаты может быть предусмотрена исключительно при 
  безналичной форме оплаты, при условии если оформлено платежное поручение на длительное списание. Порядок 
  уплаты страховой премии (страховых взносов) определяется в договоре страхования. Страховая премия или первый страховой взнос
  должны быть оплачены до даты начала действия договора страхования.</span></p>
  </td>
 </tr>
 
<tr style='mso-yfti-irow:23;page-break-inside:avoid;height:1.0pt'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:1.9pt'><p class=MsoNormal style='margin-left:5.4pt;text-indent:-5.4pt'><span
  style='font-size:8.0pt;mso-ansi-language:RU'>7.7. При оплате страхового взноса в рассрочку страховыми взносами раз в год, раз в полгода или раз в квартал 
Страхователю предоставляется 45-дневный льготный период для оплаты очередного (не первого) страхового взноса, считая 
с даты, в которую в соответствии с условиями Договора страхования должен быть оплачен очередной страховой взнос. При 
оплате страхового взноса в рассрочку страховыми взносами раз в месяц Страхователю предоставляется 30-дневный льготный 
период для оплаты очередного (не первого) страхового взноса, считая с даты, в которую в соответствии с условиями 
Договора страхования должен быть оплачен очередной страховой взнос. Если Страхователь не уплатил очередной страховой 
взнос по истечении льготного периода, то договор страхования прекращает свое действие с даты, следующей за датой 
окончания льготного периода".</span></p>
  </td>
 </tr>

<rw:getValue id="t_flg" src="flg"/> 
 <tr style='mso-yfti-irow:38'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=444 colspan=9 valign=top style='width:333.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right><span style='font-size:7.0pt;mso-ansi-language:RU'>
 <% if (t_flg.equals("0")) { %> 3. Во всем остальном, что не 
  предусмотрено настоящим Дополнительным Соглашением Стороны руководствуются положениями Полисных условий к 
  договору страхования жизни <% } else { %> 3. В соответствие с изменениями, указанными в п. 1
  настоящего Дополнительного соглашения, у Страхователя возникает обязанность доплатить Страховщику дополнительную 
  страховую премию (страховой взнос) в размере <rw:field id="" src="v_fee2"/> в срок до <rw:field id="" src="PRINT_DATE_VIPL"/> г. <% } %>
  </span></p>
  </td>
 </tr>
 <% if (!t_flg.equals("0")) { %> 
 <tr style='mso-yfti-irow:38'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=444 colspan=9 valign=top style='width:333.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right><span style='font-size:7.0pt;mso-ansi-language:RU'>
  4. Во всем остальном, что не предусмотрено настоящим Дополнительным Соглашением Стороны руководствуются 
  положениями Полисных условий к договору страхования жизни </span></p>
  </td>
 </tr>
 <% } else { %><% } %>
 <tr style='mso-yfti-irow:38'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=444 colspan=9 valign=top style='width:333.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right><span style='font-size:7.0pt;mso-ansi-language:RU'>
  <% if (t_flg.equals("0")) { %>4.<% } else { %>5.<% } %> Настоящее Дополнительное соглашение 
  вступает в силу с момента подписания его сторонами. </span></p>
  </td>
 </tr>
  </tr>
 <tr style='mso-yfti-irow:38'>
  <td width=264 colspan=3 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=444 colspan=9 valign=top style='width:333.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right><span style='font-size:7.0pt;mso-ansi-language:RU'>
  <% if (t_flg.equals("0")) { %>5.<% } else { %>6.<% } %> Настоящее Дополнительное Соглашение 
  подписано в двух экземплярах, имеющих одинаковую силу, по одному экземпляру для каждой Стороны. </span></p>
  </td>
 </tr>
 
 
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
  <p class=MsoNormal><i><span style='font-size:8.0pt;mso-ansi-language:RU'>Дата подписания Дополнительного 
  соглашения (не позднее 61 дня с даты заключения Договора страхования) ___________</span></i></p>
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
  style='mso-ansi-language:RU'>ПРИЛОЖЕНИЕ № 3<o:p></o:p></span></b></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><i style='mso-bidi-font-style:normal'><span
  style='font-size:9.0pt;mso-ansi-language:RU'>Является составной и
  неотъемлемой частью полиса<span style='mso-spacerun:yes'>  </span>№ <rw:field id="" src="POLICY_NUMBER"/><o:p></o:p></span></i></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
  style='mso-ansi-language:RU'>ТАБЛИЦА ВЫКУПНЫХ СУММ ПО<span
  style='mso-spacerun:yes'>  </span>ОСНОВНОЙ ПРОГРАММЕ <o:p></o:p></span></b></span></p>
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



<rw:foreach id="f_insyearnum_dd" src="G_INSURANCE_YEAR_NUMBER_dd">
 <rw:getValue id="nnn" src="n_dd"/>

<% if (nnn.equals("101") ) { %>

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


 <rw:foreach id="f_insyearnum_d2" src="G_INSURANCE_YEAR_NUMBER_dd">

 <tr style='mso-yfti-irow:1;height:11.35pt;'>
  <td width=120 style='width:90.0pt;border:dashed windowtext 1.0pt;border-top:
  none;mso-border-top-alt:dashed windowtext .5pt;mso-border-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="YEAR_NUMBER_dd"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=132 style='width:99.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="N_dd"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=90 style='width:67.35pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_START_dd"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_END_dd"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=170 style='width:127.2pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="RANSOM_dd"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
 </tr>

 </rw:foreach>
</table>

<rw:foreach id="f_insyearnum_g" src="G_INSURANCE_YEAR_NUMBER_g">
 <rw:getValue id="ng" src="n_g"/>

<% if (ng.equals("153") ) { %>

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


 <rw:foreach id="f_insyearnum_d3" src="G_INSURANCE_YEAR_NUMBER_g">

 <tr style='mso-yfti-irow:1;height:11.35pt;'>
  <td width=120 style='width:90.0pt;border:dashed windowtext 1.0pt;border-top:
  none;mso-border-top-alt:dashed windowtext .5pt;mso-border-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="YEAR_NUMBER_g"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=132 style='width:99.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="N_g"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=90 style='width:67.35pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_START_g"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_END_g"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=170 style='width:127.2pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="RANSOM_g"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
 </tr>

 </rw:foreach>
</table>





</div>
<% } //печатать ли таблицу выкупн. сумм %>

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
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:9.0pt'>Является составной
  и неотъемлемой частью Полиса № <rw:field id="" src="pol_num"/><o:p></o:p></span></i></p>
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
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:9.0pt'>Является составной
  и неотъемлемой частью Полиса № <rw:field id="" src="pol_num"/><o:p></o:p></span></i></p>
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
  style='mso-ansi-language:RU'>ПРИЛОЖЕНИЕ № 4<o:p></o:p></span></b></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><i style='mso-bidi-font-style:normal'><span
  style='font-size:9.0pt;mso-ansi-language:RU'>Является составной и
  неотъемлемой частью полиса<span style='mso-spacerun:yes'>  </span>№ <rw:field id="" src="POLICY_NUMBER"/><o:p></o:p></span></i></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><b style='mso-bidi-font-weight:normal'><span
  style='mso-ansi-language:RU'>ТАБЛИЦА ВЫКУПНЫХ СУММ ПО<span
  style='mso-spacerun:yes'>  </span>ДОПОЛНИТЕЛЬНОЙ ПРОГРАММЕ СТРАХОВАНИЯ "ИНВЕСТ"<o:p></o:p></span></b></span></p>
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



 <rw:foreach id="f_insyearnum_ii" src="G_INSURANCE_YEAR_NUMBER_II">
 <rw:getValue id="n_ii" src="n_ii"/>

<% if (n_ii.equals("48") ) { %>

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
 

 <rw:foreach id="f_insyearnum_ii" src="G_INSURANCE_YEAR_NUMBER_II">

 <tr style='mso-yfti-irow:1;height:11.35pt;'>
  <td width=120 style='width:90.0pt;border:dashed windowtext 1.0pt;border-top:
  none;mso-border-top-alt:dashed windowtext .5pt;mso-border-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="YEAR_NUMBER_II"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=132 style='width:99.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="N_II"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=90 style='width:67.35pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_START_II"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_END_II"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=170 style='width:127.2pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="RANSOM_II"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
 </tr>

 </rw:foreach>
</table>



<rw:foreach id="f_insyearnum_dii" src="G_INSURANCE_YEAR_NUMBER_dII">
 <rw:getValue id="n_dii" src="n_dii"/>

<% if (n_dii.equals("101") ) { %>

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


 <rw:foreach id="f_insyearnum_dii" src="G_INSURANCE_YEAR_NUMBER_dII">

 <tr style='mso-yfti-irow:1;height:11.35pt;'>
  <td width=120 style='width:90.0pt;border:dashed windowtext 1.0pt;border-top:
  none;mso-border-top-alt:dashed windowtext .5pt;mso-border-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="YEAR_NUMBER_dII"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=132 style='width:99.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="N_dII"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=90 style='width:67.35pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_START_dII"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_END_dII"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=170 style='width:127.2pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="RANSOM_dII"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
 </tr>

 </rw:foreach>
</table>

<rw:foreach id="f_insyearnum_di" src="G_INSURANCE_YEAR_NUMBER_dI">
 <rw:getValue id="n_di" src="n_di"/>

<% if (n_di.equals("153") ) { %>

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


 <rw:foreach id="f_insyearnum_di" src="G_INSURANCE_YEAR_NUMBER_dI">

 <tr style='mso-yfti-irow:1;height:11.35pt;'>
  <td width=120 style='width:90.0pt;border:dashed windowtext 1.0pt;border-top:
  none;mso-border-top-alt:dashed windowtext .5pt;mso-border-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="YEAR_NUMBER_dI"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=132 style='width:99.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="N_dI"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=90 style='width:67.35pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_START_dI"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="PERIOD_END_dI"/></span></span></p>
  </td>
  <span style='mso-bookmark:table_sum'></span>
  <td width=170 style='width:127.2pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='mso-bookmark:table_sum'><span style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-ansi-language:RU'><rw:field id="" src="RANSOM_dI"/></span></span></p>
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

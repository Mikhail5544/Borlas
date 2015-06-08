<%@ include file="/inc/header_excel.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.DecimalFormat" %>

<rw:report id="report"> 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="bordero" DTDVersion="9.0.2.0.10"
beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="reestr" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
	<dataSource name="Q_1">
      <select>
      <![CDATA[
		with tmp_tab as
(         SELECT /*+ NO_MERGE*/
                 nvl(t.pol_header_id,0)                       as ph
                 ,decode(nvl(t.pol_header_id,0), 0 , t.pol_num, to_char(t.POL_HEADER_ID))    as ph_num
                 ,t.bonus_type                                as bonus_type
                 ,Upper(t.Agent_name)                         as Agent_name
                 ,sum(distinct t.prem_percent)                as prem_percent
                 ,sum(t.prem)                                 as prem
          from
               distibution_risks t
          group by nvl(t.pol_header_id,0)
                ,decode(nvl(t.pol_header_id,0), 0 , t.pol_num, to_char(t.POL_HEADER_ID))
                ,t.agent_number
                ,t.bonus_type
                ,Upper(t.Agent_name)
                ,t.prem_percent
)
,
tmp_tab_date as (SELECT /*+ NO_MERGE*/
                     nvl(t.pol_header_id,0)                    as ph
                     ,decode(nvl(t.pol_header_id,0), 0 , t.pol_num, to_char(t.POL_HEADER_ID)) as ph_num
                     ,t.bonus_type                             as bonus_type
                     ,Upper(t.Agent_name)                      as Agent_name
                     ,t.date_register                          as date_register
                     ,t.otch_period                            as otch_period
                     ,sum(distinct t.prem_percent)             as prem_percent
                     ,sum(t.prem)                              as prem
                from
                     distibution_risks t
                group by nvl(t.pol_header_id,0)
                      ,decode(nvl(t.pol_header_id,0), 0 , t.pol_num, to_char(t.POL_HEADER_ID))
                      ,t.agent_number
                      ,t.bonus_type
                      ,Upper(t.Agent_name)
                      ,t.date_register
                      ,t.otch_period
                      ,t.prem_percent
)
SELECT /*+ LEADING (t b)*/
       1 								  as rec_num,
	   null                               as vedom_num,
       null                               as version_num,
       b.policy_header_id                 as policy_header_id,
       b.pol_ser                          as pol_ser,
       nvl(b.pol_num,t.ph_num)            as pol_num,
       b.prod_id                          as prod_id,
       case when b.policy_header_id is null
         then 'OPS'
         else b.prod_name
       end                                as prod_name,
       b.t_prod_line_option_id            as tplo_id,
       b.tplo_name                        as tplo_name,
       b.tplo_type                        as tplo_type,
       b.active_pol                       as active_p_policy_id,
       null                               as AG_CONTRACT_HEADER_ID,
       null                               as AGENT_ID,
       null                               as agent_num,

       t.Agent_name                       as agent_name,
       null                               as agent_category,
       null                               as agent_state,
       t.bonus_type                       as av_type,
       t.prem_percent                     as av_rate,
       t.prem*nvl(b.premium/sum(b.premium)
       over (partition by t.ph
                        , upper(t.Agent_name)
                        , t.bonus_type
                        , t.date_register
                        , prem_percent),1)  as commission,

       t.date_register                         as date_calc_borlas,
       t.otch_period                           as date_report
  FROM
       tmp_tab_date t,
       (select /*+ LEADING(tm ph) NO_MERGE*/
               ph.policy_header_id,
               pp.pol_ser,
               pp.pol_num,
               ph.policy_id active_pol,
               tp.product_id prod_id,
               tp.DESCRIPTION prod_name,
               pc.t_prod_line_option_id,
               tplo.description tplo_name,
               decode(ig.life_property,1,'Ж',0,'НС')  tplo_type,
               sum(pc.fee) premium --сумма если несколько застрахованных
          from as_asset aas,
               p_policy pp,
               status_hist sha,
               p_pol_header ph,
               p_cover  pc,
               status_hist shp,
               t_product tp,
               t_prod_line_option tplo,
               t_product_line     pl,
               t_lob_line         ll,
               t_insurance_group  ig,
               tmp_tab            tm
         where
           ph.policy_header_id = tm.ph
           and ph.policy_id = aas.p_policy_id
           AND ph.product_id = tp.product_id
           AND pp.policy_id = ph.policy_id
           and pc.as_asset_id = aas.as_asset_id
           and sha.status_hist_id = aas.status_hist_id
           and sha.brief <> 'DELETED'
           and tplo.ID = pc.t_prod_line_option_id
           and shp.status_hist_id = pc.status_hist_id
           and shp.brief <> 'DELETED'
           and tplo.description <> 'Административные издержки'
           and tplo.description != 'Не страховые убытки'
           and pl.id = tplo.product_line_id
           and ll.t_lob_line_id = pl.t_lob_line_id
           and ig.t_insurance_group_id = ll.insurance_group_id

         group by ph.policy_header_id,
                  pp.pol_ser,
                  pp.pol_num,
                  ph.policy_id ,
                  tp.product_id ,
                  tp.DESCRIPTION ,
                  pc.t_prod_line_option_id,
                  tplo.description,
                  decode(ig.life_property,1,'Ж',0,'НС')
     )b
 WHERE 1=1
       and t.ph = b.policy_header_id (+)
	   ]]>
      </select>
      <group name="G_1">
        <dataItem name="rec_num"/>
      </group>
    </dataSource>
  </data>
</report>
</rw:objects>

<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:x="urn:schemas-microsoft-com:office:excel">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Excel.Sheet>
<meta name=Generator content="Microsoft Excel 11">
<style>
<!--table
	{mso-displayed-decimal-separator:"\.";
	mso-displayed-thousand-separator:" ";}
@page
	{margin:.75in .7in .75in .7in;
	mso-header-margin:.3in;
	mso-footer-margin:.3in;
	mso-page-orientation:landscape;}
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
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:204;
	border:none;
	mso-protection:locked visible;
	mso-style-name:???????;
	mso-style-id:0;}
td
	{mso-style-parent:style0;
	padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:204;
	mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	border:none;
	mso-background-source:auto;
	mso-pattern:auto;
	mso-protection:locked visible;
	mso-rotate:0;}
.xl65
	{mso-style-parent:style0;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	background:silver;
	mso-pattern:auto none;
	white-space:normal;}
.xl66
	{mso-style-parent:style0;
	border:.5pt solid windowtext;}
.xl67
	{mso-style-parent:style0;
	font-weight:700;}
.xl68
	{mso-style-parent:style0;
	vertical-align:middle;}
.xl69
	{mso-style-parent:style0;
	text-align:center;
	border:.5pt solid windowtext;}
.xl70
	{mso-style-parent:style0;
	font-weight:700;
	font-style:italic;}
.xl71
	{mso-style-parent:style0;
	font-weight:700;
	text-align:left;}
.xl72
	{mso-style-parent:style0;
	font-style:italic;}
.xl73
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	white-space:normal;}
.xl74
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
-->
</style>
<!--[if gte mso 9]><xml>
 <x:ExcelWorkbook>
  <x:ExcelWorksheets>
   <x:ExcelWorksheet>
    <x:Name>????1</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>300</x:DefaultRowHeight>
     <x:Print>
      <x:ValidPrinterInfo/>
      <x:PaperSizeIndex>9</x:PaperSizeIndex>
      <x:HorizontalResolution>600</x:HorizontalResolution>
      <x:VerticalResolution>600</x:VerticalResolution>
     </x:Print>
     <x:Selected/>
     <x:Panes>
      <x:Pane>
       <x:Number>3</x:Number>
       <x:ActiveRow>17</x:ActiveRow>
       <x:ActiveCol>6</x:ActiveCol>
      </x:Pane>
     </x:Panes>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
   <x:ExcelWorksheet>
    <x:Name>????2</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>300</x:DefaultRowHeight>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
   <x:ExcelWorksheet>
    <x:Name>????3</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>300</x:DefaultRowHeight>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
  </x:ExcelWorksheets>
  <x:WindowHeight>11955</x:WindowHeight>
  <x:WindowWidth>18975</x:WindowWidth>
  <x:WindowTopX>-615</x:WindowTopX>
  <x:WindowTopY>270</x:WindowTopY>
  <x:ProtectStructure>False</x:ProtectStructure>
  <x:ProtectWindows>False</x:ProtectWindows>
 </x:ExcelWorkbook>
</xml><![endif]-->
</head>

<body link=blue vlink=purple>

<table border=0 cellspacing=0 cellpadding=0 width=750 style='width:750.0pt;border:none'>
<tr><td colspan=22><p style='text-align:center;font-size:12.0pt'><b>РАЗМАЗКА КВ БАНКИ / БРОКЕРЫ</b></p></td></tr>
</tr>
</table>
<br>

<table border=0 cellspacing=0 cellpadding=0 width=750
 style='width:750.0pt;font-size:8.0pt;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'> 
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td width=50 style='width:50.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Номер ведомости</b></p></td>
<td width=50 style='width:200.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Версия ведомости</b></p></td>
<td width=200 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>POLICY_HEADER_ID</b></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Серия полиса</b></p></td>
<td width=50 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Номер полиса</b></p></td>
<td width=50 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>PRODUCT_ID</b></p></td>
<td width=50 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Продукт</b></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>T_PROD_LINE_OPTION</b></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Название программы</b></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Тип: Ж / НС</b></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>ACTIVE_P_POLICY_ID</b></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>AG_CONTRACT_HEADER_ID</b></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>AGENT_ID</b></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Номер агента</b></p></td>
 <td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>ФИО агента</b></p></td>
 <td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Категория агента</b></p></td>
 <td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Статус агента</b></p></td>
 <td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Тип АВ</b></p></td>
 <td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Ставка</b></p></td>
 <td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>КВ</b></p></td>
 <td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Дата расчета в Борлас</b></p></td>
 <td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Отчетный период</b></p></td>
</tr>
<rw:foreach id="F2" src="G_1">
<tr>
<td width=50 style='mso-number-format:"@";width:50.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="vedom_num"/></p></td>
<td width=50 style='mso-number-format:"@";width:50.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="version_num"/></p></td>
<td width=200 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="policy_header_id"/></p></td>
<td width=50 style='mso-number-format:"@";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="pol_ser"/></p></td>
<td width=50 style='mso-number-format:"@";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="pol_num"/></p></td>
<td width=50 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="prod_id"/></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="prod_name"/></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="tplo_id"/></p></td>
<td width=80 style='mso-number-format:"@";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="tplo_name"/></p></td>
<td width=80 style='mso-number-format:"@";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="tplo_type"/></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="active_p_policy_id"/></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="AG_CONTRACT_HEADER_ID"/></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="AGENT_ID"/></p></td>
<td width=80 style='mso-number-format:"@";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="agent_num"/></p></td>
<td width=80 style='mso-number-format:"0\.00";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="agent_name"/></p></td>
<td width=50 style='mso-number-format:"@";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="agent_category"/></p></td>
<td width=50 style='mso-number-format:"@";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="agent_state"/></p></td>
<td width=50 style='mso-number-format:"@";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="av_type"/></p></td>
<td width=50 style='mso-number-format:"0\.00";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="av_rate"/></p></td>
<td width=50 style='mso-number-format:"0\.00";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="commission"/></p></td>
<td width=50 style='mso-number-format:"dd\/mm\/yyyy";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="date_calc_borlas"/></p></td>
<td width=50 style='mso-number-format:"dd\/mm\/yyyy";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="date_report"/></p></td>
</tr>
</rw:foreach>	
</table>

</body>

</html>


</rw:report>

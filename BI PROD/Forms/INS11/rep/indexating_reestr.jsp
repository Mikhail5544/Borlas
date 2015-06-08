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
   <userParameter name="P_POL_INDEX_HEADER_ID"/>
    <userParameter name="P_MONTH" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="SYS_DATE" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_YEAR" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
       <dataSource name="Q_1">
      <select>
      <![CDATA[  SELECT num,
       date_index,
       POL_SER,
       POL_NUM,
       status,
       issuer_name,
       START_DATE,
       version_num,
       /****************/
       fee_idx,
       fee_pred,
       fee_idx - fee_pred increase_fee,
       /***************/
       ins_amount_idx,
       ins_amount_pred,
       ins_amount_idx - ins_amount_pred increase_amount,
       /*****************/
       cur_agent,
       manager,
       department,
       ids,
       end_date,
       coll_method,
       str_addr,
       city_name,
       distr_name,
       reg_name,
       prov_name,
       country_name,
       primary_addr,
       addr_type,
       annual,
       addr_type,
       kol_str,
       order_num,
       product,
       p_sz,
       p_sp,
       cur_name,
       1 num_str
FROM
(SELECT pih.num,
       to_char(pih.date_index,'dd.mm.yyyy') date_index,
       pp.POL_SER,
       pp.POL_NUM,
       ins.doc.get_doc_status_name(pii.POLICY_INDEX_ITEM_ID) status,
       ins.ent.obj_name('CONTACT', ins.PKG_POLICY.GET_POLICY_HOLDER_ID(pp.POLICY_ID))
                                                                  issuer_name,
       to_char(ph.START_DATE,'dd.mm.yyyy') START_DATE,
       pp.version_num,
       (SELECT NVL(SUM(NVL(pc.fee,0)),0)
          FROM ins.p_policy pp1, ins.as_asset aa,
               ins.p_cover pc,
               ins.ven_status_hist st,
               ins.t_prod_line_option pro,
               ins.t_product_line pl
         WHERE pp1.pol_header_id = ph.policy_header_id
           AND pp1.policy_id = aa.p_policy_id
           AND aa.as_asset_id = pc.as_asset_id
           AND pc.status_hist_id = st.status_hist_id
           AND st.brief != 'DELETED'
           AND pc.t_prod_line_option_id = pro.ID
           AND pro.product_line_id = pl.ID
           AND pp1.policy_id = pii.policy_id
           AND upper(pl.description) NOT IN (/*'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ' заявка №170286,*/'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ НА ВОССТАНОВЛЕНИЕ')
           AND ins.doc.get_last_doc_status_name(pp1.policy_id) = 'Индексация') fee_idx,
       (SELECT NVL(SUM(NVL(pc.fee,0)),0)
        FROM ins.p_policy pol,
             ins.as_asset a,
             ins.p_cover pc,
             ins.ven_status_hist st,
             ins.t_prod_line_option pro,
             ins.t_product_line pl
        WHERE a.as_asset_id = pc.as_asset_id
              AND pc.t_prod_line_option_id = pro.ID
              AND pro.product_line_id = pl.ID
              AND pc.status_hist_id = st.status_hist_id
              AND st.brief != 'DELETED'
              AND upper(pl.description) NOT IN (/*'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ' заявка №170286,*/'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ НА ВОССТАНОВЛЕНИЕ')
              AND pol.policy_id = (SELECT pola.prev_ver_id
                                   FROM ins.p_pol_header pha,
                                        ins.p_policy pola,
                                        ins.policy_index_item iia,
                                        ins.ven_policy_index_header piha
                                   WHERE piha.policy_index_header_id = iia.policy_index_header_id
                                     AND piha.policy_index_header_id = pih.policy_index_header_id
                                     AND iia.policy_header_id = ph.policy_header_id
                                     AND pola.policy_id = iia.policy_id
                                     AND pha.policy_header_id = iia.policy_header_id
                                     AND pola.pol_header_id = pha.policy_header_id
                                     )
              AND pol.policy_id = a.p_policy_id
              AND pol.pol_header_id = (SELECT iia.policy_header_id
                                       FROM ins.policy_index_item iia,
                                            ins.ven_policy_index_header piha
                                       WHERE piha.policy_index_header_id = iia.policy_index_header_id
                                         AND piha.policy_index_header_id = pih.policy_index_header_id
                                         AND iia.policy_header_id = ph.policy_header_id
                                         )
       ) fee_pred,
       /***************/
         (SELECT NVL(pc.ins_amount,0)
          FROM ins.p_policy pp1, ins.as_asset aa,
               ins.p_cover pc,
               ins.ven_status_hist st,
               ins.t_prod_line_option pro,
               ins.t_product_line pl,
               ins.t_product_line_type plt
         WHERE pp1.pol_header_id = ph.policy_header_id
           AND pp1.policy_id = aa.p_policy_id
           AND aa.as_asset_id = pc.as_asset_id
           AND pc.t_prod_line_option_id = pro.ID
           AND pro.product_line_id = pl.ID
           AND pc.status_hist_id = st.status_hist_id
           AND st.brief != 'DELETED'
           AND plt.product_line_type_id = pl.product_line_type_id
           AND plt.brief = 'RECOMMENDED'
           AND pp1.policy_id = pii.policy_id
           AND ins.doc.get_last_doc_status_name(pp1.policy_id) = 'Индексация') ins_amount_idx,
       (SELECT NVL(pc.ins_amount,0)
        FROM ins.p_policy pol,
             ins.as_asset a,
             ins.p_cover pc,
             ins.ven_status_hist st,
             ins.t_prod_line_option pro,
             ins.t_product_line pl,
             ins.t_product_line_type plt
        WHERE a.as_asset_id = pc.as_asset_id
              AND pc.t_prod_line_option_id = pro.ID
              AND pro.product_line_id = pl.ID
              AND pc.status_hist_id = st.status_hist_id
              AND st.brief != 'DELETED'
              AND plt.product_line_type_id = pl.product_line_type_id
              AND plt.brief = 'RECOMMENDED'
              AND ROWNUM = 1
              AND pol.policy_id = (SELECT pola.prev_ver_id
                                   FROM ins.p_pol_header pha,
                                        ins.p_policy pola,
                                        ins.policy_index_item iia,
                                        ins.ven_policy_index_header piha
                                   WHERE piha.policy_index_header_id = iia.policy_index_header_id
                                     AND piha.policy_index_header_id = pih.policy_index_header_id
                                     AND iia.policy_header_id = ph.policy_header_id
                                     AND pola.policy_id = iia.policy_id
                                     AND pha.policy_header_id = iia.policy_header_id
                                     AND pola.pol_header_id = pha.policy_header_id
                                     )
              AND pol.policy_id = a.p_policy_id
              AND pol.pol_header_id = (SELECT iia.policy_header_id
                                       FROM ins.policy_index_item iia,
                                            ins.ven_policy_index_header piha
                                       WHERE piha.policy_index_header_id = iia.policy_index_header_id
                                         AND piha.policy_index_header_id = pih.policy_index_header_id
                                         AND iia.policy_header_id = ph.policy_header_id
                                         )
       ) ins_amount_pred,
       /*****************/
       c.obj_name_orig cur_agent,
       ins.GetManagerByDate(SYSDATE, ach.ag_contract_header_id) manager,
       d.NAME department,
       to_char(ph.ids) ids,
       to_char(pp.end_date,'dd.mm.yyyy') end_date,
       tcm.description coll_method,
       ca_addr.street_name||', '||ca_addr.house_nr||', '||ca_addr.building_name||', '||ca_addr.appartment_nr str_addr,
       ca_addr.city_name,
       ca_addr.distr_name,
       ca_addr.reg_name,
       ca_addr.prov_name,
       ca_addr.country_name,
       ins.pkg_contact.get_address_name(ins.pkg_contact.get_primary_address(ins.PKG_POLICY.GET_POLICY_HOLDER_ID(pp.POLICY_ID))) primary_addr,
       to_char(pp.start_date,'dd.mm.yyyy') annual,
       ca_addr.addr_type,
       (SELECT tmp.pages_count
        FROM TMP_STORED_REPORTS tmp
        WHERE tmp.document_id = ph.policy_header_id
              AND tmp.parent_id = :P_POL_INDEX_HEADER_ID      
        ) kol_str,
        (SELECT tmp.order_num
        FROM TMP_STORED_REPORTS tmp
        WHERE tmp.document_id = ph.policy_header_id
              AND tmp.parent_id = :P_POL_INDEX_HEADER_ID
         ) order_num,
         prod.description product,
     pkg_rep_utils.to_money_sep(
     (SELECT NVL(SUM(NVL(ac.amount,0)) - sum(Pkg_Payment.get_set_off_amount(d.document_id, NULL, NULL)),0)
         FROM ins.doc_doc dd,
           ins.ac_payment ac,
           ins.document d
     WHERE dd.child_id = ac.payment_id
         AND ac.payment_id = d.document_id
         AND d.doc_status_ref_id IN (SELECT rf.doc_status_ref_id
                                    FROM ins.doc_status_ref rf
                                     WHERE rf.brief IN ('TO_PAY','NEW')
                                    )
        AND dd.parent_id IN (SELECT pola.policy_id
                             FROM ins.p_policy pola
                             WHERE pola.pol_header_id = ph.policy_header_id
                            )
        AND d.doc_templ_id = (SELECT dt.doc_templ_id FROM ins.doc_templ dt WHERE dt.brief = 'PAYMENT')
        AND ac.plan_date < (SELECT pol.start_date
                 FROM ins.policy_index_item ii,
                      ins.ven_policy_index_header pih,
                      ins.p_policy pol
                 WHERE pih.policy_index_header_id = ii.policy_index_header_id
                   AND pih.policy_index_header_id = :P_POL_INDEX_HEADER_ID
                   AND ii.policy_header_id = ph.policy_header_id
                   AND pol.policy_id = ii.policy_id
                 )
                 ) 
    )
           p_sz,
    pkg_rep_utils.to_money_sep(
    (SELECT NVL(SUM(NVL(ac.amount,0)),0)
     FROM ins.doc_doc dd,
           ins.ac_payment ac,
           ins.document d
    WHERE dd.child_id = ac.payment_id
       AND ac.payment_id = d.document_id
       AND d.doc_status_ref_id = (SELECT rf.doc_status_ref_id
                                 FROM ins.doc_status_ref rf
                                 WHERE rf.brief = 'PAID')
       AND dd.parent_id IN (SELECT pola.policy_id
                             FROM ins.p_policy pola
                             WHERE pola.pol_header_id = ph.policy_header_id
                             )
      AND d.doc_templ_id = (SELECT dt.doc_templ_id FROM ins.doc_templ dt WHERE dt.brief = 'PAYMENT')
      AND ac.plan_date = (SELECT pol.start_date
                          FROM ins.p_policy pol,
                                ins.policy_index_item ii,
                                ins.ven_policy_index_header pih
                          WHERE pih.policy_index_header_id = ii.policy_index_header_id
                            AND pih.policy_index_header_id = :P_POL_INDEX_HEADER_ID
                            AND ii.policy_header_id = ph.policy_header_id
                            AND pol.policy_id = ii.policy_id
                          ) 
              )
             +
    (SELECT NVL(sum(Pkg_Payment.get_set_off_amount(d.document_id, NULL, NULL)),0)
      FROM ins.doc_doc dd,
           ins.ac_payment ac,
           ins.document d
      WHERE dd.child_id = ac.payment_id
        AND ac.payment_id = d.document_id
        AND d.doc_status_ref_id IN (SELECT rf.doc_status_ref_id
                                    FROM ins.doc_status_ref rf
                                    WHERE rf.brief IN ('TO_PAY')
                                    )
        AND dd.parent_id IN (SELECT pola.policy_id
                             FROM ins.p_policy pola
                             WHERE pola.pol_header_id = ph.policy_header_id
                            )
        AND d.doc_templ_id = (SELECT dt.doc_templ_id FROM ins.doc_templ dt WHERE dt.brief = 'PAYMENT')
        AND ac.plan_date = (SELECT pol.start_date
                            FROM ins.policy_index_item ii,
                                 ins.ven_policy_index_header pih,
                                 ins.p_policy pol
                            WHERE pih.policy_index_header_id = ii.policy_index_header_id
                              AND pih.policy_index_header_id = :POL_INDEX_HEAD_ID
                              AND ii.policy_header_id = ph.policy_header_id
                              AND pol.policy_id = ii.policy_id
                            )
            )   
      )      
              p_sp,
     fd.brief cur_name
  FROM ins.VEN_POLICY_INDEX_HEADER pih,
       ins.VEN_POLICY_INDEX_ITEM pii,
       ins.document di,
       ins.ven_p_pol_header ph,
       ins.fund fd,
       ins.VEN_P_POLICY pp,
       ins.t_product prod,
       ins.AG_CONTRACT_HEADER ach,
       ins.contact c,
       ins.department d,
       ins.t_collection_method tcm,
       (SELECT ca.street_name,
               ca.city_name,
               ca.district_name distr_name,
               ca.region_name reg_name,
               ca.province_name prov_name,
               cntr.description country_name,
               ca.zip,
               ca.house_nr,
               ca.appartment_nr,
               ca.building_name,
               ca.id as adress_id,
               (SELECT tat.description
               FROM ins.cn_contact_address cna,
                    ins.t_address_type tat
               WHERE cna.adress_id = ca.id
                     AND tat.id = cna.address_type)
               /*'на EDU_TEST недоступно'*/ addr_type
        FROM ins.cn_address ca,
             ins.t_country cntr
        WHERE ca.country_id = cntr.id(+)
              AND EXISTS (SELECT NULL
                          FROM ins.cn_contact_address cac
                          WHERE cac.adress_id = ca.id
                                AND cac.status != 0
                          )
        ) ca_addr
 WHERE ph.policy_header_id = pii.POLICY_HEADER_ID
   AND pih.policy_index_header_id = pii.policy_index_header_id
   AND pp.policy_id = pii.policy_id
   AND c.contact_id = ach.agent_id
   AND ph.product_id = prod.product_id
   AND ach.ag_contract_header_id = ins.pkg_renlife_utils.get_p_agent_current(ph.policy_header_id)
   AND ach.agency_id = d.department_id
   AND tcm.id = pp.collection_method_id
   AND di.document_id = pii.policy_index_item_id
   AND ins.pkg_contact.get_ltrs_address(ins.PKG_POLICY.GET_POLICY_HOLDER_ID(pp.POLICY_ID)) = ca_addr.adress_id
   AND di.doc_status_ref_id = (select rf.doc_status_ref_id from ins.doc_status_ref rf where rf.brief = 'INDEXATING')
   AND pih.policy_index_header_id = :P_POL_INDEX_HEADER_ID
   AND ph.fund_id = fd.fund_id
   /*AND ph.ids = 1920094770*/
   AND EXISTS (SELECT NULL
               FROM TMP_STORED_REPORTS tmp
               WHERE tmp.document_id = ph.policy_header_id
                     AND tmp.parent_id = :P_POL_INDEX_HEADER_ID
               )
)


   ]]>
      </select>
      <group name="group_data">
        <dataItem name="num_str"/>
      </group>
    </dataSource>
  </data>
<programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin

select to_char(trunc(sysdate),'dd.mm.yyyy'),
	to_char(trunc(sysdate),'mm'),
       to_char(trunc(sysdate),'yyyy')
into :SYS_DATE, :P_MONTH, :P_YEAR
from dual;

return (TRUE);
end;]]>
      </textSource>
    </function>
  </programUnits>
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

<table x:str border=0 cellpadding=0 cellspacing=0 width=741 style='border-collapse:
 collapse;table-layout:fixed;width:557pt'>
 <col width=48 style='mso-width-source:userset;mso-width-alt:1755;width:36pt'>
 <col width=82 style='mso-width-source:userset;mso-width-alt:2998;width:62pt'>
 <col width=87 style='mso-width-source:userset;mso-width-alt:3181;width:65pt'>
 <col width=61 style='mso-width-source:userset;mso-width-alt:2230;width:46pt'>
 <col width=84 style='mso-width-source:userset;mso-width-alt:3072;width:63pt'>
 <col width=164 style='mso-width-source:userset;mso-width-alt:5997;width:123pt'>
 <col width=110 style='mso-width-source:userset;mso-width-alt:4022;width:83pt'>
 <col width=105 style='mso-width-source:userset;mso-width-alt:3840;width:79pt'>
  <tr class=xl68 height=62 style='mso-height-source:userset;height:46.5pt'>
  <td colspan=27 height=62 class=xl73 width=741 style='height:46.5pt;width:557pt'>Реестр договоров с предложением индексации
  </td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td class=xl65 width=82 style='border-top:none;border-left:none;width:62pt'>Номер</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Исходящий номер</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Дата индексации</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Серия</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Номер</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Статус</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Страхователь</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Продукт</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Дата договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Индексированный взнос</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Неиндексированный взнос</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Увеличение страхового взноса в валюте договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Страховая сумма после Индексации</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Страховая сумма до Индексации</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Увеличение страховой суммы по основной программе в валюте договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Валюта</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Сумма задолженности</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Из них оплачено</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Действующий агент</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Менеджер</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Подразделение</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ИДС</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Дата окончания</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Вид расчетов</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Строка адреса</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Город</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Населенный пункт</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Район</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Регион</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Страна</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Адрес</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Тип адреса</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Годовщина</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Кол-во страниц</td>
 </tr>
 
 <rw:foreach id="fi2" src="group_data">
 <tr height=20 style='height:15.0pt'>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="num"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="order_num"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="date_index"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="POL_SER"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="POL_NUM"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="status"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="issuer_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="product"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="START_DATE"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="fee_idx"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="fee_pred"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="increase_fee"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="ins_amount_idx"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="ins_amount_pred"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="increase_amount"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="cur_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="p_sz"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="p_sp"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="cur_agent"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="manager"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="department"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="ids"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="end_date"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="coll_method"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="str_addr"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="city_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="distr_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="reg_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="prov_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="country_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="primary_addr"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="addr_type"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="annual"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="kol_str"></rw:field></td>
 </tr>
 
 </rw:foreach>
 
<tr height=40 style='height:30.0pt;mso-xlrowspan:2'>
  <td height=40 colspan=20 style='height:30.0pt;mso-ignore:colspan'></td>
 </tr>
 <![if supportMisalignedColumns]>
 <tr height=0 style='display:none'>
  <td width=48 style='width:36pt'></td>
  <td width=82 style='width:62pt'></td>
  <td width=87 style='width:65pt'></td>
  <td width=61 style='width:46pt'></td>
  <td width=84 style='width:63pt'></td>
  <td width=164 style='width:123pt'></td>
  <td width=110 style='width:83pt'></td>
  <td width=105 style='width:79pt'></td>
 </tr>
 <![endif]>
</table>

</body>

</html>


</rw:report>

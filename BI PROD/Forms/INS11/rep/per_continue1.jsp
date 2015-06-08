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
    <userParameter name="PH_BIRTH" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PA_DOC" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="adr_name" datatype="character" width="1000"
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
	 <userParameter name="addendum_note" datatype="character" width="2000"
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
	 <userParameter name="sys_year" datatype="character"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="sys_month" datatype="character"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	  <userParameter name="notice_date" datatype="character"
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
	<userParameter name="asset_id" datatype="number" precision="10"
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
      <![CDATA[ select fund_id from fund]]>
      </select>
      <displayInfo x="2.01073" y="0.58198" width="1.77788" height="0.50788"/>
      <group name="G_years">
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

  -- Номер полиса, 2.Страхователь, 3. Застрахованное лицо     
   begin
  select  
       -- Полис
    ak.brief,
    decode(pp.pol_ser,null,pp.pol_num,pp.pol_ser || '-' || pp.pol_num),
    pp.notice_ser||pp.notice_num,
	to_char(ph.start_date,'dd.mm.yyyy'),
    ph.fund_id,
	to_char(sysdate,'mm') sys_month,
	to_char(sysdate,'yyyy') sys_year,
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
		   NVL(ca.name, pkg_contact.get_address_name(ca.id)) address_name
    into :BRIEF_PRODUCT,:POL_NUM,:P_NOTICE,:notice_date,:CUR_POLICY,:sys_month,:sys_year,:PROGRAMMA,:P_SYSDATE,:TYPE_CONT,:POL_HOLDER,:PH_BIRTH,:PH_DOC,:POL_ASS,:PA_BIRTH,:PA_DOC, :PA_PERIODICH, :PA_PER, :WAITING_PERIOD_END_DATE, :PA_ROW_PRIL, :PA_KOD_VAL,:PA_KOD_VAL_UP,:adr_name
    from t_product ak, ven_p_policy pp, ven_p_pol_header ph, ven_as_asset a , ven_as_assured s, contact cont, VEN_T_PAYMENT_TERMS vt, VEN_FUND vf,
    (select p.policy_id, count(1) row_cnt 
   from ven_policy_cash_surr p, ven_policy_cash_surr_d d 
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :P_POLICY_ID group by p.policy_id) rcnt,
  ( select document_id, start_date from (
    select ds.document_id, ds.start_date from ven_doc_status ds, ven_doc_status_ref dsr 
    where ds.doc_status_ref_id = dsr.doc_status_ref_id(+)
      and dsr.brief = 'ACTIVE' and ds.document_id = :P_POLICY_ID order by ds.start_date desc ) where rownum = 1) ds,
v_temp_company comp,
cn_person per,
cn_address ca
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
     and pp.PAYMENT_TERM_ID = vt.ID(+)
	 and cont.contact_id = per.contact_id
     and pkg_contact.get_primary_address(cont.contact_id) = ca.ID;
  exception
    when no_data_found then :WAITING_PERIOD_END_DATE := ' ';
    
  end;

  return (TRUE);

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



<body lang=RU style='tab-interval:36.0pt'>

<div class=Section1>

<br><br><br><br><br><br><br>
<table width="52%" border="1" align="right">
 <tr>
  <td align=right style="font-size: 13;">Кому:</td> 
  <td style="font-size: 13;"><rw:field id="" src="POL_HOLDER"/></td> 
 </tr> 
 <tr>
  <td align=right style="font-size: 13;">Куда:</td>
  <td style="font-size: 13;"><rw:field id="" src="adr_name"/></td> 
 </tr>

</table>

<br>


<p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'>
<b><span style='mso-bidi-font-size:11.0pt;font-family:Times New Roman'>Дата: <rw:field id="" src="P_SYSDATE"/>
</span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'>
<b><span style='mso-bidi-font-size:11.0pt;font-family:Times New Roman'>Исх.№ __________-<rw:field id="" src="sys_month"/>/<rw:field id="" src="sys_year"/></span></b></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>&nbsp;</p>

<p class=MsoNormal style='margin-top:6.0pt;margin-justify:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:center;text-indent:1.0cm'>
<span style='mso-bidi-font-size:12.0pt;font-family:Times New Roman'><i><b>Уважаемый (ая) <rw:field id="" src="POL_HOLDER"/>!</i></b></span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>&nbsp;</p>

<p class=MsoNormal style='margin-top:6.0pt;margin-justify:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'>
<span style='mso-bidi-font-size:12.0pt;font-family:Times New Roman'>Мы рассмотрели Ваше заявление от _____ / _____ / 20 ____ 
 с просьбой о продлении периода оценки страхового риска, и уведомляем Вас настоящим письмом о том, что
 период оценки страхового риска по полису страхования № <rw:field id="" src="POL_NUM"/> от <rw:field id="" src="notice_date"/> г.
 продлен до _____ / _____ / 20 ____.
</span></p>

<br><br><br>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>&nbsp;</p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:10.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>С наилучшими пожеланиями,</span></i></b></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>
<img width=132 height=55 src="<%=g_ImagesRoot%>/letter_remind/podpis0001.jpg" alt="Гусев Владислав"></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:9.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>Директор Операционного департамента</span></i></b></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:9.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>Гусев Владислав</span></i></b></p>

</div>

</body>

</html>

<!--
</rw:report> 
-->

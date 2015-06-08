<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<rw:report id="report"> 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="paym_req" DTDVersion="9.0.2.0.10"
beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="paym_req" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="EVENT_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	 
	 <userParameter name="flag" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	  <userParameter name="fund_id" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="start_date" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="num" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="code" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="pol" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="brief" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="amount_in_words" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="amount" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="bank" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="bank_adr" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="bic" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="account_corr" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="beneficiary" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 
	  <userParameter name="s_amount" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	  <userParameter name="amount_in_words" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 
	 <userParameter name="beneficiary_adr" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="inn" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="account_nr" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="krc" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="cpp" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="note" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="prod" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="region_code" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="prep" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="status_claim" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 
    <dataSource name="Q_CLAIM">
      <select>
      <![CDATA[ select code from fund where fund_id = 'RUR']]>
      </select>
      <displayInfo x="0.21875" y="0.09387" width="1.33325" height="0.19995"/>
      <group name="G_CLAIM">
	  </group>
    </dataSource>
  </data>
  
   <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin
declare
  n varchar2(10);
  k varchar2(10);
  s varchar2(10);
  t varchar2(10);
 begin
 
	k := pkg_renlife_utils.f_param('pkg_renlife_utils.set_tmptable_vipl',:EVENT_ID);


select ph.fund_id
into :fund_id
from ven_c_claim_header ch,
     ven_c_claim clm,
     ven_p_policy p,
     p_pol_header ph
where ch.p_policy_id = p.policy_id
       and ch.active_claim_id = clm.c_claim_id
       and ph.policy_header_id = p.pol_header_id
       and ch.c_event_id = :EVENT_ID
       and rownum = 1;
 
	select LTRIM(TO_CHAR(nvl(sum(case when real_z > 0 then (case when viplata - real_z > 0 then viplata - real_z else viplata end) else viplata end),0), '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')),
		   pkg_utils.money2speech(sum(case when real_z > 0 then (case when viplata - real_z > 0 then viplata - real_z else viplata end) else viplata end),:fund_id)
	into :s_amount, :amount_in_words
	from temp_tmptable_vipl
	where peril <> 1;

 end;		
  
  begin
select start_date,
        NUM,
        pol,
        LTRIM(TO_CHAR(amount, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) amount,
        brief,
        flag,
        bank,
        bank_adr,
        bic,
        account_corr,
        beneficiary,
        beneficiary_adr,
        inn,
		account_nr,
        cpp,
        note,
        prod,
        region_code,
        prep,
        status_claim,
		code
into :start_date,:num,:pol,:amount,:brief,:flag,:bank,:bank_adr,:bic,:account_corr,:beneficiary,:beneficiary_adr,:inn,:account_nr,:cpp,:note,:prod,:region_code,:prep,:status_claim,:code
from
(select start_date,
        NUM,
        pol,
        case when s_z >= sum(amount) then 1 else 0 end flag,
        case when s_z >= sum(amount) then s_z else s_v end amount,
		brief,
        fund_id,
        bank,
        bank_adr,
        bic,
        account_corr,
        beneficiary,
        beneficiary_adr,
        inn,
        account_nr,
        cpp,
        note,
        prod,
        region_code,
        prep,
        status_claim,
		code
 from (
   SELECT rownum rn, to_char(ph.start_date,'dd.mm.yyyy') start_date,
       e.NUM,
       decode(p.pol_ser, null, p.pol_num, p.pol_ser || '-' || p.pol_num) pol,
       nvl(pkg_renlife_utils.ret_amount_active(ch.c_claim_header_id,'PAYORDER_SETOFF'),0) s_z,
       nvl(pkg_renlife_utils.ret_amount_active(ch.c_claim_header_id,'PAYORDER'),0) s_v,
       d.payment_sum amount,
       f_pol.brief,
       f_pol.fund_id,
       bb.bank_name||' '||bb.branch_name bank,
       adr.address_name bank_adr,
       bic.id_value bic,
       krc.id_value account_corr,--bb.account_corr,
       --ent.obj_name(a.ent_id, a.as_asset_id) beneficiary,
       cont.obj_name_orig beneficiary,
       adr.address_name beneficiary_adr,
       inn.id_value inn,
	   --krc.id_value krc,
       bb.account_nr,
       cpp.id_value cpp,
       lic.id_value note,
       prod.brief prod,
       '' region_code,
       decode(us.name,'Панферова Валерия Олеговна','Панферова В.О.',
	   				 'Асланова Елена Федоровна','Асланова Е.Ф.',
					 'Кутенкова Марина Юрьевна','Кутенкова М.Ю.',
					 'Вера Вадимовна Лопотовская','Лопотовская В.В.', 
					 us.name) prep,
       nvl(to_char(d_stat.status_claim,'dd.mm.yyyy'),'') status_claim,
	   nvl(substr(pr.kladr_code,1,2),'') code
	   --decode(doc.get_last_doc_status_name(ch.active_claim_id),'Принято решение', to_char(clm.claim_status_date,'dd.mm.yyyy'),'') status_claim
   FROM ven_c_claim_header ch,
   ven_c_claim clm,
       ven_p_policy p,
       p_pol_header ph,
	   department dep,
       organisation_tree ot,
       t_province pr,
       t_product prod,
       fund f_pol,
       ven_c_event e,
       ven_c_event_contact ec,
       cn_contact_bank_acc bb,
       (select ii.id_value, ii.contact_id
        from cn_contact_ident ii
        where ii.id_type = 10) bic,
        (select ii.id_value, ii.contact_id
        from cn_contact_ident ii
        where ii.id_type = 1) inn,
        (select ii.id_value, ii.contact_id
        from cn_contact_ident ii
        where ii.id_type = 20022) cpp,
        (select ii.id_value, ii.contact_id
        from cn_contact_ident ii
        where ii.id_type = 11) krc,
		(select ii.place_of_issue id_value, ii.contact_id
        from cn_contact_ident ii
        where ii.id_type = 20027
			  and ii.is_default = 1) lic,
        v_cn_contact_address adr,
        contact cont,
        ven_sys_user us,
        c_damage d,
        (select max(trunc(ds.start_date)) status_claim,
                   ch.c_claim_header_id
        from doc_status ds,
             ven_c_claim_header ch
        where ds.document_id = ch.active_claim_id
              and ds.doc_status_ref_id = 128
        group by ch.c_claim_header_id) d_stat
         
 WHERE ch.p_policy_id = p.policy_id
       and d.c_claim_id = ch.active_claim_id
       and ph.policy_header_id = p.pol_header_id
       and prod.product_id = ph.product_id
	   and ch.active_claim_id = clm.c_claim_id
       and f_pol.fund_id = ph.fund_id

       and ec.cn_person_id = bb.contact_id(+)
       and bb.bank_id = bic.contact_id(+)
       and bb.bank_id = inn.contact_id(+)
       and bb.bank_id = cpp.contact_id(+)
	   and bb.bank_id = krc.contact_id(+)
       and bb.bank_id = adr.contact_id(+)
       and d_stat.c_claim_header_id(+) = ch.c_claim_header_id
	    --and ass.assured_contact_id = lic.contact_id(+)
      --and ass.assured_contact_id = cont.contact_id
       and cont.contact_id = lic.contact_id(+)
       and ch.declarant_id = ec.c_event_contact_id
       and ec.cn_person_id = cont.contact_id
       
       and us.sys_user_name = USER
	   and dep.department_id(+) = ph.agency_id
	   and ot.organisation_tree_id(+) = dep.org_tree_id
	   and pr.province_id(+) = ot.province_id
       AND ch.c_event_id = e.c_event_id
       and e.c_event_id = ch.c_event_id
       and e.c_event_id = :EVENT_ID)
       group by start_date,
                NUM,
                pol,
                brief,
                fund_id,
                bank,
                s_z,
                s_v,
                case when s_z > s_v then 1 else 0 end,
                bank_adr,
                bic,
                account_corr,
                beneficiary,
                beneficiary_adr,
                inn,
                account_nr,
                cpp,
                note,
                prod,
                region_code,
                prep,
				status_claim,
				code) 
where rownum = 1;
exception
    when no_data_found then :start_date:='';:num:='';:pol:='';:amount:=0;
							:brief:='';:flag:=0;:bank:='';:bank_adr:='';:bic:='';
							:account_corr:='';:beneficiary:='';:beneficiary_adr:='';:inn:='';
							:account_nr:='';:cpp:='';:note:='';:prod:='';:region_code:='';:prep:='';:status_claim:='';:code:='';
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
<link rel=File-List href="?????????%20?????????1.files/filelist.xml">
<title>????????? ?????????? / Payment Request</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>V</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>V</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>33</o:TotalTime>
  <o:Created>2009-06-04T06:09:00Z</o:Created>
  <o:LastSaved>2009-06-04T06:09:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>247</o:Words>
  <o:Characters>1412</o:Characters>
  <o:Lines>11</o:Lines>
  <o:Paragraphs>3</o:Paragraphs>
  <o:CharactersWithSpaces>1656</o:CharactersWithSpaces>
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
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:51.05pt 39.7pt 51.05pt 51.05pt;
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
table.MsoTableGrid
	{mso-style-name:"????? ???????";
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
 <o:shapedefaults v:ext="edit" spidmax="2050"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=RU style='tab-interval:35.4pt'>

<div class=Section1>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=638 colspan=6 valign=top style='width:478.55pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'>Платежное требование / </b><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='mso-ansi-language:
  EN-US'>Payment Request</span><o:p></o:p></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:3.45pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.45pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.45pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.45pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.45pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.45pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'>Дата</span></b><span style='font-size:9.0pt'> / </span><span
  lang=EN-US style='font-size:9.0pt;mso-ansi-language:EN-US'>Date:</span><span
  style='font-size:9.0pt'><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:
  EN-US'><rw:field id="" src="status_claim"/><o:p></o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'>Номер</span></b><span style='font-size:9.0pt'> / </span><span
  lang=EN-US style='font-size:9.0pt;mso-ansi-language:EN-US'>Number:</span><span
  style='font-size:9.0pt'><o:p></o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:
  EN-US'><rw:field id="" src="num"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:2.55pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Номер договора </span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE><span class=GramE>C</span>ontract</span>
  <span class=SpellE>number</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:
  EN-US'><rw:field id="" src="pol"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;height:2.55pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Сумма платежа</span></b><span
  style='font-size:9.0pt'>/<span class=SpellE>Amount</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:
  EN-US'><rw:field id="" src="s_amount"/><o:p></o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Валюта</span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Currency</span><o:p></o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:
  EN-US'><rw:field id="" src="brief"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;height:2.55pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Сумма прописью </span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Amount</span> <span
  class=SpellE>in</span> <span class=SpellE>words</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="amount_in_words"/></span><span
  lang=EN-US style='font-size:9.0pt;mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:9;height:2.55pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:10'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Банк получателя / </span></b><span
  class=SpellE><span style='font-size:9.0pt'>Beneficiary</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>Bank</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="bank"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:11;height:2.55pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:12'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span class=SpellE><span class=GramE><b><span
  style='font-size:9.0pt'>C</span></b></span><b><span style='font-size:9.0pt'>Страна</span></b></span><b><span
  style='font-size:9.0pt'>, адрес банка получателя </span></b><span
  style='font-size:9.0pt'>/</span><span style='font-size:9.0pt;mso-ansi-language:
  EN-US'> </span><span class=SpellE><span style='font-size:9.0pt'>Beneficiary</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>Bank</span> <span class=SpellE>adress</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="bank_adr"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:13;height:2.55pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:14;height:6.7pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.7pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>БИК/ </span></b><span
  style='font-size:9.0pt'>BIC<o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.7pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:6.7pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="bic"/><o:p></o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:6.7pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>корр. счет банка</span></b><b><span
  style='font-size:9.0pt;mso-ansi-language:EN-US'> <span lang=EN-US>/</span></span></b><span
  class=SpellE><span style='font-size:9.0pt'>correspondence</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>bank</span> <span class=SpellE>account</span><o:p></o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:6.7pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="account_corr"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:15;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:16'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Получатель</span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Beneficiary</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span class=SpellE><span style='font-size:9.0pt'><rw:field id="" src="beneficiary"/></span><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:17;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:18;height:6.8pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.8pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Адрес получателя /</span></b><span
  style='font-size:9.0pt'> <span class=SpellE>Beneficiary</span> <span
  class=SpellE>address</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:6.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="beneficiary_adr"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:19;height:4.35pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.35pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.35pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.35pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:4.35pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:4.35pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:20;height:7.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:7.05pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>ИНН банка получателя</span></b><b><span
  lang=EN-US style='font-size:9.0pt;mso-ansi-language:EN-US'> /</span></b><span
  class=SpellE><span style='font-size:9.0pt'>Beneficiary</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>tax</span> <span class=SpellE>code</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:7.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:7.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="inn"/><o:p></o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:7.05pt'>
  <p class=MsoNormal><span class=SpellE><b><span style='font-size:9.0pt'>расч</span></b></span><b><span
  style='font-size:9.0pt'>. счет получателя</span></b><b><span
  style='font-size:9.0pt;mso-ansi-language:EN-US'> </span></b><b><span
  style='font-size:9.0pt'>/</span></b><span class=SpellE><span
  style='font-size:9.0pt'>Beneficiary</span></span><span style='font-size:9.0pt'>
  <span class=SpellE>account</span><o:p></o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:7.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="account_nr"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:21;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:22;height:2.55pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>КПП</span></b><span
  style='font-size:9.0pt'>/CPP<o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="cpp"/><o:p></o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:23;height:5.8pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:5.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:24;height:6.4pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Назначение платежа</span></b><b><span
  style='font-size:9.0pt;mso-ansi-language:EN-US'> </span></b><b><span
  style='font-size:9.0pt'>/</span></b><span class=SpellE><span
  style='font-size:9.0pt'>Payment</span></span><span style='font-size:9.0pt'> <span
  class=SpellE>purpose</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <rw:getValue id="fl" src="flag"/>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:6.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'>
  <% if (fl.equals("1")) {%> Учет страховой выплаты в счет очередного страхового взноса <%} 
  else {%> Выплата страхового обеспечения <%} %> <o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:25;height:6.8pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:6.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:6.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:26'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Примечания</span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Comments</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="note"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:27;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-top:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:28'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Наименование <span
  class=SpellE>кост-центра</span>/ </span></b><span class=SpellE><span
  style='font-size:9.0pt'>Name</span></span><span style='font-size:9.0pt'> of <span
  class=SpellE>cost</span> <span class=SpellE>center</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span class=SpellE><span style='font-size:9.0pt'> </span><o:p></o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:29;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:30'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Код продукта / </span></b><span
  class=SpellE><span style='font-size:9.0pt'>Product</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>code</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:
  EN-US'><rw:field id="" src="prod"/></span><span style='font-size:9.0pt'><o:p></o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Код региона</span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Region</span> <span
  class=SpellE>code</span><o:p></o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="code"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:31;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:32'>
  <td width=207 valign=top style='width:155.6pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Вид платежа</span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Type</span> of <span
  class=SpellE>payment</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Перестрахование/ </span></b><span
  class=SpellE><span style='font-size:9.0pt'>Reinsurance</span></span><span
  style='font-size:9.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:33;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:black;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <rw:getValue id="flg" src="flag"/>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal style='tab-stops:68.95pt'><b><span style='font-size:9.0pt'>
  <% if (flg.equals("1")) {%> Учет страховой выплаты в счет очередного страхового взноса <%} 
  else {%> Выплата страхового обеспечения возмещения / Claims maturity<%} %><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:34;height:3.9pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.9pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.9pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.9pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Агентское вознаграждение/
  </span></b><span class=SpellE><span style='font-size:9.0pt'>Brokerage</span></span><span
  style='font-size:9.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:35;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal style='tab-stops:102.95pt'><b><span style='font-size:9.0pt'>Возврат 
  премии/</span></b><span class=SpellE><span style='font-size:9.0pt'>Premium</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>return</span>, <span
  class=SpellE>surrender</span><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:36;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Экпертиза</span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Examination</span><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:37;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=240 colspan=2 valign=top style='width:180.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=54 valign=top style='width:40.25pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:38'>
  <td width=207 valign=top style='width:155.6pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Налогообложение платежа /
  </span></b><span class=SpellE><span style='font-size:9.0pt'>Tax</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>deductible</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=240 colspan=2 valign=top style='width:180.0pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>НДС включен/</span></b><span
  style='font-size:9.0pt'> VAT <span class=SpellE>Included</span><o:p></o:p></span></p>
  </td>
  <td width=54 valign=top style='width:40.25pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'>Сумма НДС/VAT <span
  class=SpellE>amount</span><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:39;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:black;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=240 colspan=2 valign=bottom style='width:180.0pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>НДС не взимается</span></b><span
  style='font-size:9.0pt'>/ VAT <span class=SpellE>Not</span> <span
  style='mso-spacerun:yes'> </span></span><span lang=EN-US style='font-size:
  9.0pt;mso-ansi-language:EN-US'>A</span><span class=SpellE><span
  style='font-size:9.0pt'>pplicable</span></span><b><span style='font-size:
  9.0pt'><o:p></o:p></span></b></p>
  </td>
  <td width=54 valign=top style='width:40.25pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'> <o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:40'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=240 colspan=2 valign=top style='width:180.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=54 valign=top style='width:40.25pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:41'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Подготовлено</span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Prepared</span> <span
  class=SpellE>by</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt'><rw:field id="" src="prep"/></span><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:42;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-top:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:43'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Одобрено /</span></b><span
  style='font-size:9.0pt'> <span class=SpellE>Accepted</span> <span
  class=SpellE>by</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span class=SpellE><span
  style='font-size:9.0pt'>Лопотовская</span></span><span style='font-size:9.0pt'>
  В.В.<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:44;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-top:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:45'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='tab-stops:69.45pt'><b><span style='font-size:9.0pt'>Главный 
  бухгалтер /</span></b><span class=SpellE><span style='font-size:9.0pt'>Chief</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>accountant</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt'>Белоусова Е.В.<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:46'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-top:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:47;mso-yfti-lastrow:yes'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Операционный директор
  /<span style='mso-spacerun:yes'>  </span></span></b><span class=SpellE><span
  style='font-size:9.0pt'>Operational</span></span><span style='font-size:9.0pt'>
  <span class=SpellE>director</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt'>Гусев В.В.<o:p></o:p></span></p>
  </td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=207 style='border:none'></td>
  <td width=16 style='border:none'></td>
  <td width=120 style='border:none'></td>
  <td width=120 style='border:none'></td>
  <td width=54 style='border:none'></td>
  <td width=121 style='border:none'></td>
 </tr>
 <![endif]>
</table>

<p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

</div>

</body>

</html>

</rw:report>

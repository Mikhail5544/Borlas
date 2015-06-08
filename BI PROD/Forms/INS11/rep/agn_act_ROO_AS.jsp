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
    <userParameter name="P_DEPT_ID"/>
	<userParameter name="DEPT" datatype="character" width="150"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_DEPT_NAME"/>
	<userParameter name="PAR_DATE" datatype="character" width="150"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_DATE_BEGIN" datatype="character" width="150"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="REP_DATE" datatype="character" width="150"
     defaultWidth="0" defaultHeight="0"/>
       <dataSource name="Q_1">
      <select>
      <![CDATA[select count(*) OVER (order by dep.name) rn, 
       nvl(nvl(nvl(nvl(tdir.tdch,tdir2.td2ch),tdir3.td3ch),tdir4.td4ch),tdir5.td5ch) tdch,
       nvl(nvl(nvl(nvl(tdir.tddep,tdir2.td2dep),tdir3.td3dep),tdir4.td4dep),tdir5.td5dep) tddep,
       nvl(nvl(nvl(nvl(tdir.tdnum,tdir2.td2num),tdir3.td3num),tdir4.td4num),tdir5.td5num) tdnum,
       nvl(nvl(nvl(nvl(tdir.tdname,tdir2.td2name),tdir3.td3name),tdir4.td4name),tdir5.td5name) tdname,
       nvl(nvl(nvl(nvl(tdir.tdcat,tdir2.td2cat),tdir3.td3cat),tdir4.td4cat),tdir5.td5cat) tdcat,
       nvl(nvl(nvl(nvl(tdir.tdfnum,tdir2.td2fnum),tdir3.td3fnum),tdir4.td4fnum),tdir5.td5fnum) tdfnum,
       nvl(nvl(nvl(nvl(tdir.tdfname,tdir2.td2fname),tdir3.td3fname),tdir4.td4fname),tdir5.td5fname) tdfname,
       nvl(nvl(nvl(nvl(tdir.tdfcat,tdir2.td2fcat),tdir3.td3fcat),tdir4.td4fcat),tdir5.td5fcat) tdfcat,
       nvl(nvl(nvl(nvl(tdir.tdrnum,tdir2.td2rnum),tdir3.td3rnum),tdir4.td4rnum),tdir5.td5rnum) tdrnum,
       nvl(nvl(nvl(nvl(tdir.tdrname,tdir2.td2rname),tdir3.td3rname),tdir4.td4rname),tdir5.td5rname) tdrname,
       nvl(nvl(nvl(nvl(tdir.tdrcat,tdir2.td2rcat),tdir3.td3rcat),tdir4.td4rcat),tdir5.td5rcat) tdrcat,
       nvl(dch,dir2.d2ch) dch,
       nvl(ddep,dir2.d2dep) ddep,
       nvl(dnum,dir2.d2num) dnum,
       nvl(dname,dir2.d2name) dname,
       nvl(dcat,dir2.d2cat) dcat,
       nvl(dfnum,dir2.d2fnum) dfnum,
       nvl(dfname,dir2.d2fname) dfname,
       nvl(dfcat,dir2.d2fcat) dfcat,
       nvl(drnum,dir2.d2rnum) drnum,
       nvl(drname,dir2.d2rname) drname,
       nvl(drcat,dir2.d2rcat) drcat,
       mch,
       mdep,
       mnum,
       mname,
       mcat,
       mfnum,
       mfname,
       mfcat,
       mrnum,
       mrname,
       mrcat,
       ch.description ach,
       dep.name adep,
       d.num anum,
       c.obj_name_orig aname,
       cat.category_name acat,
       fnum,
       fname,
       fcat,
       rnum,
       rname,
       rcat

from ins.ag_agent_tree tr,
     ag_contract_header agh,
     ag_documents agn,
     ag_doc_type agt,
     document d,
     ag_contract ag,
     contact c,
     department dep,
     ag_category_agent cat,
     t_sales_channel ch,
     
     (select d.num fnum,
             c.obj_name_orig fname,
             cat.category_name fcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   		 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) fleader,
      (select d.num rnum,
             c.obj_name_orig rname,
             cat.category_name rcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   		 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) recruit,
     
     (select d.num mnum,
       c.obj_name_orig mname,
       dep.name mdep,
       cat.category_name mcat,
       agh.ag_contract_header_id mid,
       ch.description mch,
       tr.ag_parent_header_id mpid,
       mfnum,
       mfname,
       mfcat,
       mrnum,
       mrname,
       mrcat
from ins.ag_agent_tree tr,
     ag_contract_header agh,
     document d,
     ag_contract ag,
     contact c,
     department dep,
     ag_category_agent cat,
     t_sales_channel ch,
     (select d.num mfnum,
             c.obj_name_orig mfname,
             cat.category_name mfcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   		 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) fleader,
      (select d.num mrnum,
             c.obj_name_orig mrname,
             cat.category_name mrcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   	 	 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) recruit
        
where tr.ag_contract_header_id = agh.ag_contract_header_id
	  and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
      and agh.ag_contract_header_id = d.document_id
      and nvl(agh.is_new,0) = 1
      and agh.ag_contract_header_id = ag.contract_id
      and ag.agency_id = dep.department_id
      and agh.agent_id = c.contact_id
      and cat.ag_category_agent_id = ag.category_id
      and agh.t_sales_channel_id = ch.id
      
      and fleader.ag_contract_id(+) = ag.contract_f_lead_id
      and recruit.ag_contract_id(+) = ag.contract_recrut_id
      
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between tr.date_begin and tr.date_end
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between ag.date_begin and ag.date_end
      --and sysdate between tr.date_begin and tr.date_end
      --and sysdate between ag.date_begin and ag.date_end
      and cat.ag_category_agent_id = 3
      --and dep.name = 'Ставрополь Подразделение 3'
	  and dep.department_id = :P_DEPT_ID
     ) manag,
     
     (select d.num dnum,
       c.obj_name_orig dname,
       dep.name ddep,
       cat.category_name dcat,
       ch.description dch,
       agh.ag_contract_header_id did,
       tr.ag_parent_header_id dpid,
       dfnum,
       dfname,
       dfcat,
       drnum,
       drname,
       drcat
from ins.ag_agent_tree tr,
     ag_contract_header agh,
     document d,
     ag_contract ag,
     contact c,
     department dep,
     ag_category_agent cat,
     t_sales_channel ch,
     (select d.num dfnum,
             c.obj_name_orig dfname,
             cat.category_name dfcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   	 	 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) fleader,
      (select d.num drnum,
             c.obj_name_orig drname,
             cat.category_name drcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   		 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) recruit
where tr.ag_contract_header_id = agh.ag_contract_header_id
	  and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
      and agh.ag_contract_header_id = d.document_id
      and nvl(agh.is_new,0) = 1
      and agh.ag_contract_header_id = ag.contract_id
      and ag.agency_id = dep.department_id
      and agh.agent_id = c.contact_id
      and cat.ag_category_agent_id = ag.category_id
      and agh.t_sales_channel_id = ch.id
      and fleader.ag_contract_id(+) = ag.contract_f_lead_id
      and recruit.ag_contract_id(+) = ag.contract_recrut_id
      
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between tr.date_begin and tr.date_end
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between ag.date_begin and ag.date_end     
      --and sysdate between tr.date_begin and tr.date_end
      --and sysdate between ag.date_begin and ag.date_end
      and (cat.ag_category_agent_id between 3 and 30)
      --and dep.name = 'Ставрополь Подразделение 3'
	  and dep.department_id = :P_DEPT_ID
     ) dir,
     
(select d.num d2num,
       c.obj_name_orig d2name,
       dep.name d2dep,
       cat.category_name d2cat,
       ch.description d2ch,
       agh.ag_contract_header_id d2id,
       tr.ag_parent_header_id d2pid,
       d2fnum,
       d2fname,
       d2fcat,
       d2rnum,
       d2rname,
       d2rcat
from ins.ag_agent_tree tr,
     ag_contract_header agh,
     document d,
     ag_contract ag,
     contact c,
     department dep,
     ag_category_agent cat,
     t_sales_channel ch,
     (select d.num d2fnum,
             c.obj_name_orig d2fname,
             cat.category_name d2fcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   		 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) fleader,
      (select d.num d2rnum,
             c.obj_name_orig d2rname,
             cat.category_name d2rcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   		 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) recruit
where tr.ag_contract_header_id = agh.ag_contract_header_id
	  and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
      and agh.ag_contract_header_id = d.document_id
      and nvl(agh.is_new,0) = 1
      and agh.ag_contract_header_id = ag.contract_id
      and ag.agency_id = dep.department_id
      and agh.agent_id = c.contact_id
      and cat.ag_category_agent_id = ag.category_id
      and agh.t_sales_channel_id = ch.id
      and fleader.ag_contract_id(+) = ag.contract_f_lead_id
      and recruit.ag_contract_id(+) = ag.contract_recrut_id
      
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between tr.date_begin and tr.date_end
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between ag.date_begin and ag.date_end    
      --and sysdate between tr.date_begin and tr.date_end
      --and sysdate between ag.date_begin and ag.date_end
      and (cat.ag_category_agent_id between 4 and 30)
      --and dep.name = 'Ставрополь Подразделение 3'
	  and dep.department_id = :P_DEPT_ID
     ) dir2,
    
(select d.num tdnum,
       c.obj_name_orig tdname,
       dep.name tddep,
       cat.category_name tdcat,
       ch.description tdch,
       agh.ag_contract_header_id tdid,
       tdfnum,
       tdfname,
       tdfcat,
       tdrnum,
       tdrname,
       tdrcat
from ins.ag_agent_tree tr,
     ag_contract_header agh,
     document d,
     ag_contract ag,
     contact c,
     department dep,
     ag_category_agent cat,
     t_sales_channel ch,
     (select d.num tdfnum,
             c.obj_name_orig tdfname,
             cat.category_name tdfcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   	 	 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) fleader,
      (select d.num tdrnum,
             c.obj_name_orig tdrname,
             cat.category_name tdrcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   		 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) recruit
where tr.ag_contract_header_id = agh.ag_contract_header_id
	  and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
      and agh.ag_contract_header_id = d.document_id
      and nvl(agh.is_new,0) = 1
      and agh.ag_contract_header_id = ag.contract_id
      and ag.agency_id = dep.department_id
      and agh.agent_id = c.contact_id
      and cat.ag_category_agent_id = ag.category_id
      and agh.t_sales_channel_id = ch.id
      and fleader.ag_contract_id(+) = ag.contract_f_lead_id
      and recruit.ag_contract_id(+) = ag.contract_recrut_id
      
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between tr.date_begin and tr.date_end
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between ag.date_begin and ag.date_end     
      --and sysdate between tr.date_begin and tr.date_end
      --and sysdate between ag.date_begin and ag.date_end
      and cat.ag_category_agent_id > 20
      --and dep.name = 'Ставрополь Подразделение 3'
	  --and dep.department_id = 13720--:P_DEPT_ID
     ) tdir,
     
(select d.num td2num,
       c.obj_name_orig td2name,
       dep.name td2dep,
       cat.category_name td2cat,
       ch.description td2ch,
       agh.ag_contract_header_id td2id,
       td2fnum,
       td2fname,
       td2fcat,
       td2rnum,
       td2rname,
       td2rcat
from ins.ag_agent_tree tr,
     ag_contract_header agh,
     document d,
     ag_contract ag,
     contact c,
     department dep,
     ag_category_agent cat,
     t_sales_channel ch,
     (select d.num td2fnum,
             c.obj_name_orig td2fname,
             cat.category_name td2fcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   	 	 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) fleader,
      (select d.num td2rnum,
             c.obj_name_orig td2rname,
             cat.category_name td2rcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   		 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) recruit
where tr.ag_contract_header_id = agh.ag_contract_header_id
	  and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
      and agh.ag_contract_header_id = d.document_id
      and nvl(agh.is_new,0) = 1
      and agh.ag_contract_header_id = ag.contract_id
      and ag.agency_id = dep.department_id
      and agh.agent_id = c.contact_id
      and cat.ag_category_agent_id = ag.category_id
      and agh.t_sales_channel_id = ch.id
      and fleader.ag_contract_id(+) = ag.contract_f_lead_id
      and recruit.ag_contract_id(+) = ag.contract_recrut_id
      
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between tr.date_begin and tr.date_end
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between ag.date_begin and ag.date_end   
      --and sysdate between tr.date_begin and tr.date_end
      --and sysdate between ag.date_begin and ag.date_end
      and cat.ag_category_agent_id > 20
      --and dep.name = 'Ставрополь Подразделение 3'
	  --and dep.department_id = :P_DEPT_ID
     ) tdir2,
(select d.num td3num,
       c.obj_name_orig td3name,
       dep.name td3dep,
       cat.category_name td3cat,
       ch.description td3ch,
       agh.ag_contract_header_id td3id,
       td3fnum,
       td3fname,
       td3fcat,
       td3rnum,
       td3rname,
       td3rcat
from ins.ag_agent_tree tr,
     ag_contract_header agh,
     document d,
     ag_contract ag,
     contact c,
     department dep,
     ag_category_agent cat,
     t_sales_channel ch,
     (select d.num td3fnum,
             c.obj_name_orig td3fname,
             cat.category_name td3fcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   	 	 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) fleader,
      (select d.num td3rnum,
             c.obj_name_orig td3rname,
             cat.category_name td3rcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   		 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) recruit
where tr.ag_contract_header_id = agh.ag_contract_header_id
	  and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
      and agh.ag_contract_header_id = d.document_id
      and nvl(agh.is_new,0) = 1
      and agh.ag_contract_header_id = ag.contract_id
      and ag.agency_id = dep.department_id
      and agh.agent_id = c.contact_id
      and cat.ag_category_agent_id = ag.category_id
      and agh.t_sales_channel_id = ch.id
      and fleader.ag_contract_id(+) = ag.contract_f_lead_id
      and recruit.ag_contract_id(+) = ag.contract_recrut_id
      
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between tr.date_begin and tr.date_end
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between ag.date_begin and ag.date_end    
      --and sysdate between tr.date_begin and tr.date_end
      --and sysdate between ag.date_begin and ag.date_end
      and cat.ag_category_agent_id > 20
      --and dep.name = 'Ставрополь Подразделение 3'
	  --and dep.department_id = :P_DEPT_ID
     ) tdir3,
(select d.num td4num,
       c.obj_name_orig td4name,
       dep.name td4dep,
       cat.category_name td4cat,
       ch.description td4ch,
       agh.ag_contract_header_id td4id,
       td4fnum,
       td4fname,
       td4fcat,
       td4rnum,
       td4rname,
       td4rcat
from ins.ag_agent_tree tr,
     ag_contract_header agh,
     document d,
     ag_contract ag,
     contact c,
     department dep,
     ag_category_agent cat,
     t_sales_channel ch,
     (select d.num td4fnum,
             c.obj_name_orig td4fname,
             cat.category_name td4fcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   	 	 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) fleader,
      (select d.num td4rnum,
             c.obj_name_orig td4rname,
             cat.category_name td4rcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   		 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) recruit
where tr.ag_contract_header_id = agh.ag_contract_header_id
	  and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
      and agh.ag_contract_header_id = d.document_id
      and nvl(agh.is_new,0) = 1
      and agh.ag_contract_header_id = ag.contract_id
      and ag.agency_id = dep.department_id
      and agh.agent_id = c.contact_id
      and cat.ag_category_agent_id = ag.category_id
      and agh.t_sales_channel_id = ch.id
      and fleader.ag_contract_id(+) = ag.contract_f_lead_id
      and recruit.ag_contract_id(+) = ag.contract_recrut_id
      
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between tr.date_begin and tr.date_end
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between ag.date_begin and ag.date_end
      --and sysdate between tr.date_begin and tr.date_end
      --and sysdate between ag.date_begin and ag.date_end
      and cat.ag_category_agent_id > 20
      --and dep.name = 'Ставрополь Подразделение 3'
     ) tdir4,
(select d.num td5num,
       c.obj_name_orig td5name,
       dep.name td5dep,
       cat.category_name td5cat,
       ch.description td5ch,
       agh.ag_contract_header_id td5id,
       td5fnum,
       td5fname,
       td5fcat,
       td5rnum,
       td5rname,
       td5rcat
from ins.ag_agent_tree tr,
     ag_contract_header agh,
     document d,
     ag_contract ag,
     contact c,
     department dep,
     ag_category_agent cat,
     t_sales_channel ch,
     (select d.num td5fnum,
             c.obj_name_orig td5fname,
             cat.category_name td5fcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   	 	 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) fleader,
      (select d.num td5rnum,
             c.obj_name_orig td5rname,
             cat.category_name td5rcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
	   		 and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) recruit
where tr.ag_contract_header_id = agh.ag_contract_header_id
	  and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
      and agh.ag_contract_header_id = d.document_id
      and nvl(agh.is_new,0) = 1
      and agh.ag_contract_header_id = ag.contract_id
      and ag.agency_id = dep.department_id
      and agh.agent_id = c.contact_id
      and cat.ag_category_agent_id = ag.category_id
      and agh.t_sales_channel_id = ch.id
      and fleader.ag_contract_id(+) = ag.contract_f_lead_id
      and recruit.ag_contract_id(+) = ag.contract_recrut_id
      
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between tr.date_begin and tr.date_end
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between ag.date_begin and ag.date_end
      --and sysdate between tr.date_begin and tr.date_end
      --and sysdate between ag.date_begin and ag.date_end
      and cat.ag_category_agent_id > 50
      --and dep.name = 'Ставрополь Подразделение 3'
     ) tdir5
     
where tr.ag_contract_header_id = agh.ag_contract_header_id
      and agh.ag_contract_header_id = d.document_id
	  and doc.get_doc_status_name(agh.ag_contract_header_id) not in ('Расторгнут')
      
      and agn.ag_contract_header_id = agh.ag_contract_header_id
      and agn.ag_doc_type_id = agt.ag_doc_type_id
      and agt.brief = 'NEW_AD'
      and doc.get_doc_status_name(agn.ag_documents_id) in ('В архиве ЦО','Проверено в ЦО')
      
      and nvl(agh.is_new,0) = 1
      and agh.ag_contract_header_id = ag.contract_id
      and ag.agency_id = dep.department_id
      and agh.agent_id = c.contact_id
      and cat.ag_category_agent_id = ag.category_id
      
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between tr.date_begin and tr.date_end
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between ag.date_begin and ag.date_end
      --and sysdate between tr.date_begin and tr.date_end
      --and sysdate between ag.date_begin and ag.date_end
      and cat.category_name = 'Агент'
      --and dep.name = 'Ставрополь Подразделение 3'
	  and dep.department_id = :P_DEPT_ID
      and ch.id = agh.t_sales_channel_id
      
      and fleader.ag_contract_id(+) = ag.contract_f_lead_id
      and recruit.ag_contract_id(+) = ag.contract_recrut_id
      
      and manag.mid(+) = tr.ag_parent_header_id
      and manag.mpid = dir.did(+)
      and tr.ag_parent_header_id = dir2.d2id(+)
      
      and tdir.tdid(+) = dir.dpid
      and tdir2.td2id(+) = dir2.d2pid
	  and tdir3.td3id(+) = manag.mpid
	  and tdir4.td4id(+) = tr.ag_parent_header_id
	  and tdir5.td5id(+) = tr.ag_parent_header_id
      --and d.num = '10704'
]]>
      </select>
      <group name="GR_AGENT">
        <dataItem name="rn"/>
      </group>
    </dataSource>
  </data>
<programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin

begin
	select dep.name
		into :DEPT
	from department dep
	where dep.department_id = :P_DEPT_ID;
exception
	   when no_data_found then :DEPT := '';
end;	

select to_char(sysdate,'dd.mm.yyyy') 
	into :REP_DATE from dual;

select :P_DATE_BEGIN 
	into :PAR_DATE from dual;

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

<% 
  int rec_count_all = 0;
  int rec_count_current = 0;
%>
<rw:foreach id="fi0" src="GR_AGENT">
  <rw:getValue id="j_rec_count" src="rn"/>
  <% rec_count_all = new Integer(j_rec_count).intValue(); %>
</rw:foreach>

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
  <td colspan=21 height=62 class=xl73 width=741 style='height:46.5pt;width:557pt'>
  АКТ СВЕРКИ СТРУКТУРЫ АГЕНТСКОЙ СЕТИ</td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl73 width=48 colspan=3 style='height:30.0pt;border-top:none;
  width:36pt'>Агентство</td>
  <td height=40 class=xl73 width=48 colspan=3 style='height:30.0pt;border-top:none;
  width:36pt'><rw:field id="" src="dept"/></td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl73 width=48 colspan=3 style='height:30.0pt;border-top:none;
  width:36pt'>Отчетный месяц:</td>
  <td height=40 class=xl73 width=48 colspan=3 style='height:30.0pt;border-top:none;
  width:36pt'><rw:field id="" src="par_date"/></td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl73 width=48 colspan=3 style='height:30.0pt;border-top:none;
  width:36pt'>Дата составления:</td>
  <td height=40 class=xl73 width=48 colspan=3 style='height:30.0pt;border-top:none;
  width:36pt'><rw:field id="" src="rep_date"/></td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl73 width=48 colspan=35 style='height:30.0pt;border-top:none;
  width:36pt'></td>
 </tr>
 
<tr height=40 style='height:30.0pt'>
  <td height=40 class=xl65 width=50 rowspan=2 style='height:30.0pt;border-top:none;width:36pt'>№ п/п</td>
  <td class=xl65 width=50 colspan=5 style='border-top:none;border-left:none;width:50pt'>Территориальный Директор</td>
  <td class=xl65 width=50 colspan=5 style='border-top:none;border-left:none;width:50pt'>Директор</td>
  <td class=xl65 width=50 colspan=5 style='border-top:none;border-left:none;width:50pt'>Менеджер</td>
  <td class=xl65 width=50 colspan=5 style='border-top:none;border-left:none;width:50pt'>Агент</td>
  <td height=40 class=xl65 width=50 rowspan=2 style='height:30.0pt;border-top:none;width:36pt'>Примечания: ФИО, уволен / переведен в менеджеры / переведен в субагенты / переведен в директоры</td>
</tr>
<tr height=40 style='height:30.0pt'>
 
  <td class=xl65 width=82 style='border-top:none;border-left:none;width:62pt'>Вид агентской сети (SAS / DSF)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Агентство</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>№АД</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ФИО Территориального Директора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Категория Территориального Директора</td>
  <td class=xl65 width=82 style='border-top:none;border-left:none;width:62pt'>Вид агентской сети (SAS / DSF)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Агентство</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>№АД</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ФИО Директора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Категория Директора</td>
  <td class=xl65 width=82 style='border-top:none;border-left:none;width:62pt'>Вид агентской сети (SAS / DSF)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Агентство</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>№АД</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ФИО Менеджер</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Категория Менеджер</td>
  <td class=xl65 width=82 style='border-top:none;border-left:none;width:62pt'>Вид агентской сети (SAS / DSF)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Агентство</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>№АД</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ФИО Агента</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Категория Агента</td>
  
 </tr>
 
 <rw:foreach id="fi2" src="GR_AGENT">
 
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl69 style='height:15.0pt;border-top:none'><%=++rec_count_current%></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="tdch"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="tddep"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="tdnum"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="tdname"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="tdcat"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="dch"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="ddep"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="dnum"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="dname"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="dcat"></rw:field></td>
   <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mch"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mdep"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mnum"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mname"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mcat"></rw:field></td>
   <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="ach"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="adep"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="anum"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="aname"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="acat"></rw:field></td>
 </tr>
 
 </rw:foreach>
 
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

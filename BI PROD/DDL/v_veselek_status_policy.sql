CREATE OR REPLACE FORCE VIEW V_VESELEK_STATUS_POLICY AS
SELECT COUNT(*) as kol,
       jj.status_name,
       /*jj.agency_name,
       tt.description as prod_desc,*/
       case extract(month from to_date(trunc(nvl(jj.status_date,'01-01-2007'))))
                                                                 when 1 then '01'
                                                                 when 2 then '02'
                                                                 when 3 then '03'
                                                                 when 4 then '04'
                                                                 when 5 then '05'
                                                                 when 6 then '06'
                                                                 when 7 then '07'
                                                                 when 8 then '08'
                                                                 when 9 then '09'
                                                                 when 10 then '10'
                                                                 when 11 then '11'
                                                                 when 12 then '12' else '' end as mont,
       case extract(year from to_date(nvl(jj.status_date,'01-01-2007'))) when 2004 then '2004'
                                                                when 2005 then '2005'
                                                                when 2006 then '2006'
                                                                when 2007 then '2007'
                                                                when 2008 then '2008'
                                                                when 2009 then '2009'
                                                                when 2010 then '2010'
                                                                when 2011 then '2011'
                                                                when 2012 then '2012'
                                                                when 2013 then '2013' else '' end as year
FROM V_POLICY_VERSION_JOURNAL jj
     --left join t_product tt on (jj.product_id = tt.product_id)
WHERE (to_char(jj.status_date, 'DD.MM.RRRR') LIKE '%.%.200%')
      and jj.policy_id = jj.active_policy_id
      --and nvl(extract(year from to_date(START_DATE,'dd.mm.yyyy')),2005) between 2005 and 2010
group by jj.status_name, /*jj.agency_name,
       tt.description,*/ case extract(month from to_date(trunc(nvl(jj.status_date,'01-01-2007'))))
                                                                 when 1 then '01'
                                                                 when 2 then '02'
                                                                 when 3 then '03'
                                                                 when 4 then '04'
                                                                 when 5 then '05'
                                                                 when 6 then '06'
                                                                 when 7 then '07'
                                                                 when 8 then '08'
                                                                 when 9 then '09'
                                                                 when 10 then '10'
                                                                 when 11 then '11'
                                                                 when 12 then '12' else '' end,
                                                                 /*case extract(month from to_date(START_DATE,'dd.mm.yyyy')) when 1 then '������'
                                                                 when 2 then '�������'
                                                                 when 3 then '����'
                                                                 when 4 then '������'
                                                                 when 5 then '���'
                                                                 when 6 then '����'
                                                                 when 7 then '����'
                                                                 when 8 then '������'
                                                                 when 9 then '��������'
                                                                 when 10 then '�������'
                                                                 when 11 then '������'
                                                                 when 12 then '�������' else '' end*/
         case extract(year from to_date(nvl(jj.status_date,'01-01-2007'))) when 2004 then '2004'
                                                                when 2005 then '2005'
                                                                when 2006 then '2006'
                                                                when 2007 then '2007'
                                                                when 2008 then '2008'
                                                                when 2009 then '2009'
                                                                when 2010 then '2010'
                                                                when 2011 then '2011'
                                                                when 2012 then '2012'
                                                                when 2013 then '2013' else '' end
order by case extract(year from to_date(nvl(jj.status_date,'01-01-2007'))) when 2004 then '2004'
                                                                when 2005 then '2005'
                                                                when 2006 then '2006'
                                                                when 2007 then '2007'
                                                                when 2008 then '2008'
                                                                when 2009 then '2009'
                                                                when 2010 then '2010'
                                                                when 2011 then '2011'
                                                                when 2012 then '2012'
                                                                when 2013 then '2013' else '' end
;


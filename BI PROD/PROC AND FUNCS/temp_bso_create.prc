create or replace procedure temp_bso_create
is
        f NUMBER;
        numb NUMBER;
        form_n VARCHAR2 (5);
        fpred VARCHAR2 (100);
        fio VARCHAR2 (100);
        fins VARCHAR2 (100);
        n1 NUMBER;
        n2 NUMBER;
        pred number;
BEGIN


/*declare
b_num varchar2(10);
n number;
sub number;
f_name varchar2(5);
ff varchar2(100);
CURSOR c1 IS (SELECT dep.bso_num,
                     case when left(dep.bso_nummber,5) = '00000' then convert(int,right(dep.bso_num,1))
                     when left(dep.bso_num,4) = '0000' then convert(int,right(dep.bso_num,2))
                     when left(dep.bso_num,3) = '000' then convert(int,right(dep.bso_num,3))
                     when left(dep.bso_num,2) = '00' then convert(int,right(dep.bso_num,4))
                     when left(dep.bso_num,1) = '0' then convert(int,right(dep.bso_num,5))
                     when left(dep.bso_num,1) <> '0' then convert(int,dep.bso_num)
                     end as numb,
                     dep.cont_id as subj_id,
                     dep.bso_ser as form_name,
                     cc.name||' '||cc.first_name||' '||cc.middle_name as f1
              FROM temp_bso_ticketRT_12356 dep
              left join contact cc on (cc.contact_id = dep.cont_id)
              order by dep.bso_num);
BEGIN
   OPEN c1;
   LOOP
      FETCH c1 INTO b_num,n,sub,f_name,ff;
      EXIT WHEN c1%NOTFOUND;
      insert into temp_p (bso_num,numb,subj_id,form_name,f1)
      values (b_num,n,sub,f_name,ff);
   END LOOP;
   CLOSE c1;
end;*/

insert into temp_p
SELECT dep.bso_num,
       case when substr(dep.bso_num,1,5) = '00000' then to_number(substr(dep.bso_num,6,1))
            when substr(dep.bso_num,1,4) = '0000' then to_number(substr(dep.bso_num,5,2))
            when substr(dep.bso_num,1,3) = '000' then to_number(substr(dep.bso_num,4,3))
            when substr(dep.bso_num,1,2) = '00' then to_number(substr(dep.bso_num,3,4))
            when substr(dep.bso_num,1,1) = '0' then to_number(substr(dep.bso_num,2,5))
            when substr(dep.bso_num,1,1) <> '0' then to_number(dep.bso_num)
       end as numb,
       dep.cont_id as subj_id,
       dep.bso_ser as form_name,
       cc.name||' '||cc.first_name||' '||cc.middle_name as f1
FROM temp_bso_ticketRT_12356 dep
     left join contact cc on (cc.contact_id = dep.cont_id)
order by dep.bso_num;
--------------------

/*create table temp_pol (
numb1 number,
numb2 number,
type varchar2(100),
str1 varchar2(100),
str2 varchar2(100),
fio varchar2(100));*/

pred := 1000000;
f := 0;

 FOR boo_cur IN 
      (select numb,
            form_name,
            f1
     from temp_p)
  LOOP
   --   EXIT WHEN boo_cur%NOTFOUND;
      n2 := pred;
      fins := fpred;
      insert into temp_pol
    	       select n1, n2,form_n, '','', fins
    	       from temp_p
    	       where numb = numb;

       if f = 0 then
  	      n1 := numb;
	        fins := fio;
       end if;

  if numb - pred > 1 and fio = fpred then
  	n2 := pred;
	  fins := fpred;
  	insert into temp_pol
    	select n1, n2, form_n,'','', fins
    	from temp_p
    	where numb = numb;
	  n1 := numb;
  end if;
  f := 1;
  pred := numb;
  fpred := fio;

   END LOOP;

--truncate table temp_p;

/*update temp_pol
set str1 = case when 6 - LENGTH(  rtrim(to_char(numb1)) ) = 5 then '00000' + rtrim(to_char(numb1))
			  when 6 - LENGTH(  rtrim(to_char(numb1)) ) = 4 then '0000' + rtrim(to_char(numb1))
			  when 6 - LENGTH(  rtrim(to_char(numb1)) ) = 3 then '000' + rtrim(to_char(numb1))
			  when 6 - LENGTH(  rtrim(to_char(numb1)) ) = 2 then '00' + rtrim(to_char(numb1))
			  when 6 - LENGTH(  rtrim(to_char(numb1)) ) = 1 then '0' + rtrim(to_char(numb1))
			  else rtrim(to_char(numb1))
			  end,
	str2 = case when 6 - LENGTH(  rtrim(to_char(numb2)) ) = 5 then '00000' + rtrim(to_char(numb2))
			  when 6 - LENGTH(  rtrim(to_char(numb2)) ) = 4 then '0000' + rtrim(to_char(numb2))
			  when 6 - LENGTH(  rtrim(to_char(numb2)) ) = 3 then '000' + rtrim(to_char(numb2))
			  when 6 - LENGTH(  rtrim(to_char(numb2)) ) = 2 then '00' + rtrim(to_char(numb2))
			  when 6 - LENGTH(  rtrim(to_char(numb2)) ) = 1 then '0' + rtrim(to_char(numb2))
			  else rtrim(to_char(numb2))
			  end;

select pol.str1,
       pol.str2,
       pol.type,
       pol.fio
from temp_pol pol;*/

--truncate table temp_pol;

end temp_bso_create;
/


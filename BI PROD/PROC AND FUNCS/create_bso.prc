create or replace procedure create_bso
as
 cursor cur_bso (p_num integer,p_ser integer) is
   select * from bso b where b.NUM = p_num and b.BSO_SERIES_ID = p_ser;
 rec_bso cur_bso%rowtype;  
 a number; 
begin 
   for rec in ( 
         SELECT b.NUM_START, 
         b.NUM_END, 
       b.BSO_HIST_TYPE_ID, 
       b.BSO_SERIES_ID, 
       bd.REG_DATE, 
       bd.CONTACT_TO_ID, 
       b.bso_doc_cont_id, 
       bd.DEPARTMENT_TO_ID, 
       b.BSO_NOTES_TYPE_ID 
    FROM bso_doc_cont b, ven_bso_document bd 
   WHERE bd.bso_document_id = b.bso_document_id 
     and bd.EXT_ID is not null
	 and B.NUM_START not like '%-%' 
   ) 
   loop 
      for rec2 in rec.num_start .. rec.num_end  
   loop 
     open cur_bso(rec2,rec.BSO_SERIES_ID);
  fetch cur_bso into rec_bso;
  if (cur_bso%notfound)then
    select sq_bso.nextval into a from dual;
    insert into ven_bso
    (
     BSO_ID         ,
     BSO_SERIES_ID  ,
     NUM            ,
     BSO_HIST_ID    
    )values
    (
      a,
   rec.BSO_SERIES_ID,
   rec2,
   null
    );
    insert into ven_BSO_HIST BH 
    ( 
     BSO_HIST_ID        , 
     BSO_ID             , 
     HIST_DATE          , 
     CONTACT_ID         , 
     HIST_TYPE_ID       , 
     BSO_DOC_CONT_ID    , 
     DEPARTMENT_ID      , 
     BSO_NOTES_TYPE_ID  , 
     ext_id 
    ) 
    values ( 
        SQ_BSO_HIST.NEXTVAL, 
     a, 
     rec.REG_DATE, 
     rec.CONTACT_TO_ID, 
     rec.BSO_HIST_TYPE_ID, 
     rec.bso_doc_cont_id, 
     rec.DEPARTMENT_TO_ID, 
     rec.BSO_NOTES_TYPE_ID, 
     0 
    );
    pkg_convert.SP_EventInfo('BSO',a,rec2);	
  end if;
     close cur_bso;
   end loop; 
   end loop; 
   update bso L 
 set l.BSO_HIST_ID = 
 (select MAX(C.BSO_HIST_ID) from (
 select 
 MAX(HIST_DATE) over (partition by  BSO_ID ) as R,
 b.* from BSO_HIST B ) C
 where C.R = C.Hist_date and C.BSO_ID = L.BSO_ID);
 end;
/


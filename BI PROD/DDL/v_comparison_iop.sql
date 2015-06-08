create or replace force view v_comparison_iop as
select c.obj_name_orig, DECODE(per.gender,0,'Æ',1,'Ì','') gender_contact, DECODE(iop.desc_gender,0,'Æ',1,'Ì','') gender_iop
from contact c,
     cn_person per,
     t_desc_iop iop
where UPPER(c.first_name)||UPPER(c.middle_name) = UPPER(iop.desc_name)||UPPER(iop.desc_middle)
      and per.contact_id = c.contact_id
      and nvl(per.no_standart_name,0) = 0
      and per.gender <> iop.desc_gender
UNION
select c.obj_name_orig, DECODE(per.gender,0,'Æ',1,'Ì','') gender_contact, DECODE(iop.desc_gender,0,'Æ',1,'Ì','') gender_iop
from contact c
     join cn_person per on (per.contact_id = c.contact_id and nvl(per.no_standart_name,0) = 0)
     left join t_desc_iop iop on (UPPER(c.first_name)||UPPER(c.middle_name)||NVL(per.gender,0) = UPPER(iop.desc_name)||UPPER(iop.desc_middle)||NVL(iop.desc_gender,0))
where 1=1
      and iop.t_desc_iop_id IS NULL;


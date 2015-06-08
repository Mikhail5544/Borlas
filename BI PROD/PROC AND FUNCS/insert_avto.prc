create or replace procedure insert_avto is
 v_marka  ven_t_vehicle_mark%rowtype;
 v_model  ven_t_main_model%rowtype;
begin
  -- ����� �� �����
  for marka in (
                 select a.naimenovanie,
                        a.id
                 from a1c_sc580_avtomobili a
                 where a.id_rod = a.id 
                   and not exists (select 1
                                    from T_VEHICLE_MARK m
                                    where trim(upper(m.name)) = trim(upper(a.naimenovanie))
                                   )
                   and  upper(a.naimenovanie)!='�������������� ������������ ��������' 
               )
  loop
   -- �������� �����
   insert into ven_t_vehicle_mark m
   (name,is_national_mark)
    values (marka.naimenovanie,0); 
    -- �������� �� �����
   select * into v_marka
   from ven_t_vehicle_mark m
   where m.name =marka.naimenovanie;  
   -- ��������� ������
   insert into ven_t_main_model 
   (t_vehicle_mark_id,name,t_vehicle_type_id)
          select  v_marka.t_vehicle_mark_id,
                  aa.naimenovanie,
                  case aa.tipts
                   when '001' then 11 -- ��������� � �����������
                   when '002' then 1  -- �������� ����������
                   when '003' then 4 -- �������� ����������
                   when '004' then 6 -- ��������
                   when '005' then 7 -- �����������
                   when '006' then 8 -- �������
                   when '007' then 9 -- ��������, �������. ���.-���. � ���� ������
                   when '008' then 2 -- ������� � �������� ����
                   when '009' then 5 -- ������� � �������� ����
                   when '010' then 10 -- ������� � ���������
                  end tipts
             from a1c_sc580_avtomobili aa
           where aa.id_rod = marka.id
             and aa.id_rod!=aa.id;  
  
  end loop;
  
  -- ����� �� �������
  for model in (
                 select mar.t_vehicle_mark_id, -- �� ����� 
                        aa.id, -- �� ����������� � 1�
                        aa.naimenovanie,
                        case aa.tipts
                         when '001' then 11 -- ��������� � �����������
                         when '002' then 1  -- �������� ����������
                         when '003' then 4 -- �������� ����������
                         when '004' then 6 -- ��������
                         when '005' then 7 -- �����������
                         when '006' then 8 -- �������
                         when '007' then 9 -- ��������, �������. ���.-���. � ���� ������
                         when '008' then 2 -- ������� � �������� ����
                         when '009' then 5 -- ������� � �������� ����
                         when '010' then 10 -- ������� � ���������
                        end tipts
                 from a1c_sc580_avtomobili a,   -- �����
                      a1c_sc580_avtomobili aa,  -- ������
                      ven_t_vehicle_mark mar
                 where a.id_rod = a.id  -- ���������� �����
                   and trim(upper(mar.name)) = trim(upper(a.naimenovanie)) -- ����� �������
                   and aa.id_rod = a.id
                   and aa.id_rod != aa.id 
                   and not exists (select 1 -- �� ������� ���
                                   from ven_t_main_model mm
                                   where trim(upper(mm.name)) = trim(upper(aa.naimenovanie))
                                     and mm.t_vehicle_mark_id = mar.t_vehicle_mark_id 
                                   )
                   and  upper(a.naimenovanie)!='�������������� ������������ ��������' 
               )
  loop
   -- ��������� ������
   insert into ven_t_main_model 
   (t_vehicle_mark_id,name,t_vehicle_type_id)
     values (model.t_vehicle_mark_id,model.naimenovanie,model.tipts);
   -- �������� �� ������
   select * into v_model
   from ven_t_main_model m
   where m.name =model.naimenovanie
     and m.t_vehicle_mark_id =model.t_vehicle_mark_id ;
   -- ��������� ����������� 
   insert into ven_t_model
   (t_vehicle_mark_id,name,power,t_main_model_id)
         select v_model.t_vehicle_mark_id,
                aaa.naimenovanie,
                aaa.moschnostls,
                v_model.t_main_model_id
         from a1c_sc580_avtomobili aaa
         where aaa.id_rod = model.id;
  end loop;
  
  -- ����� �� ������������
  for modif in (
                select aaa.naimenovanie,
                       mar.t_vehicle_mark_id,
                       mm.t_main_model_id,
                       aaa.moschnostls
                from a1c_sc580_avtomobili a,   -- �����
                     a1c_sc580_avtomobili aa,  -- ������
                     a1c_sc580_avtomobili aaa,  -- �����������
                     ven_t_vehicle_mark mar,
                     ven_t_main_model mm 
                where a.id_rod = a.id  -- ���������� �����      
                  and aa.id_rod = a.id
                  and aa.id_rod != aa.id -- ���������� ������
                  and aaa.id_rod = aa.id -- ���������� �����������
                  and trim(upper(mar.name)) = trim(upper(a.naimenovanie)) -- ����� �������
                  and mar.t_vehicle_mark_id = mm.t_vehicle_mark_id
                  and trim(upper(mm.name)) =  trim(upper(aa.naimenovanie)) -- ������ �������
                  and not exists (select 1 -- �� ������� ���
                                  from ven_t_model mmm
                                  where mmm.t_vehicle_mark_id = mm.t_vehicle_mark_id
                                    and mmm.t_main_model_id = mm.t_main_model_id
                                    and  (
                                           (
                                             trim(upper(mmm.name)) = trim(upper(aaa.naimenovanie))
                                           )
                                           or
                                           (
                                             trim(upper(replace(mmm.name,'.',','))) = trim(upper(aaa.naimenovanie))
                                           )
                                           or
                                           (
                                             trim(upper(replace(mmm.name,',','.'))) = trim(upper(aaa.naimenovanie))
                                           )
                                         )    
                                  )
                  and  upper(a.naimenovanie)!='�������������� ������������ ��������' 
                   
               )
  loop
   insert into ven_t_model
   (t_vehicle_mark_id,name,power,t_main_model_id)
   values
   (modif.t_vehicle_mark_id,modif.naimenovanie,modif.moschnostls,modif.t_main_model_id);
  end loop;             

end insert_avto;
/


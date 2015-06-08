create or replace procedure insert_avto is
 v_marka  ven_t_vehicle_mark%rowtype;
 v_model  ven_t_main_model%rowtype;
begin
  -- бегем по марка
  for marka in (
                 select a.naimenovanie,
                        a.id
                 from a1c_sc580_avtomobili a
                 where a.id_rod = a.id 
                   and not exists (select 1
                                    from T_VEHICLE_MARK m
                                    where trim(upper(m.name)) = trim(upper(a.naimenovanie))
                                   )
                   and  upper(a.naimenovanie)!='НЕОПРЕДЕЛЕННОЕ ТРАНСПОРТНОЕ СРЕДСТВО' 
               )
  loop
   -- вставили марку
   insert into ven_t_vehicle_mark m
   (name,is_national_mark)
    values (marka.naimenovanie,0); 
    -- выбираем ИД марки
   select * into v_marka
   from ven_t_vehicle_mark m
   where m.name =marka.naimenovanie;  
   -- вставляем модель
   insert into ven_t_main_model 
   (t_vehicle_mark_id,name,t_vehicle_type_id)
          select  v_marka.t_vehicle_mark_id,
                  aa.naimenovanie,
                  case aa.tipts
                   when '001' then 11 -- Мотоциклы и мотороллеры
                   when '002' then 1  -- Легковые автомобили
                   when '003' then 4 -- Грузовые автомобили
                   when '004' then 6 -- Автобусы
                   when '005' then 7 -- Троллейбусы
                   when '006' then 8 -- Трамваи
                   when '007' then 9 -- Тракторы, самоход. дор.-стр. и иные машины
                   when '008' then 2 -- Прицепы к легковым авто
                   when '009' then 5 -- Прицепы к грузовым авто
                   when '010' then 10 -- Прицепы к тракторам
                  end tipts
             from a1c_sc580_avtomobili aa
           where aa.id_rod = marka.id
             and aa.id_rod!=aa.id;  
  
  end loop;
  
  -- бегем по моделям
  for model in (
                 select mar.t_vehicle_mark_id, -- ид марки 
                        aa.id, -- ид можификации в 1с
                        aa.naimenovanie,
                        case aa.tipts
                         when '001' then 11 -- Мотоциклы и мотороллеры
                         when '002' then 1  -- Легковые автомобили
                         when '003' then 4 -- Грузовые автомобили
                         when '004' then 6 -- Автобусы
                         when '005' then 7 -- Троллейбусы
                         when '006' then 8 -- Трамваи
                         when '007' then 9 -- Тракторы, самоход. дор.-стр. и иные машины
                         when '008' then 2 -- Прицепы к легковым авто
                         when '009' then 5 -- Прицепы к грузовым авто
                         when '010' then 10 -- Прицепы к тракторам
                        end tipts
                 from a1c_sc580_avtomobili a,   -- марка
                      a1c_sc580_avtomobili aa,  -- модель
                      ven_t_vehicle_mark mar
                 where a.id_rod = a.id  -- определили марки
                   and trim(upper(mar.name)) = trim(upper(a.naimenovanie)) -- марки совпали
                   and aa.id_rod = a.id
                   and aa.id_rod != aa.id 
                   and not exists (select 1 -- но моделей нет
                                   from ven_t_main_model mm
                                   where trim(upper(mm.name)) = trim(upper(aa.naimenovanie))
                                     and mm.t_vehicle_mark_id = mar.t_vehicle_mark_id 
                                   )
                   and  upper(a.naimenovanie)!='НЕОПРЕДЕЛЕННОЕ ТРАНСПОРТНОЕ СРЕДСТВО' 
               )
  loop
   -- вставляем модель
   insert into ven_t_main_model 
   (t_vehicle_mark_id,name,t_vehicle_type_id)
     values (model.t_vehicle_mark_id,model.naimenovanie,model.tipts);
   -- выбираем ИД модель
   select * into v_model
   from ven_t_main_model m
   where m.name =model.naimenovanie
     and m.t_vehicle_mark_id =model.t_vehicle_mark_id ;
   -- вставляем модификацию 
   insert into ven_t_model
   (t_vehicle_mark_id,name,power,t_main_model_id)
         select v_model.t_vehicle_mark_id,
                aaa.naimenovanie,
                aaa.moschnostls,
                v_model.t_main_model_id
         from a1c_sc580_avtomobili aaa
         where aaa.id_rod = model.id;
  end loop;
  
  -- бегем по модификациям
  for modif in (
                select aaa.naimenovanie,
                       mar.t_vehicle_mark_id,
                       mm.t_main_model_id,
                       aaa.moschnostls
                from a1c_sc580_avtomobili a,   -- марка
                     a1c_sc580_avtomobili aa,  -- модель
                     a1c_sc580_avtomobili aaa,  -- модификация
                     ven_t_vehicle_mark mar,
                     ven_t_main_model mm 
                where a.id_rod = a.id  -- определили марки      
                  and aa.id_rod = a.id
                  and aa.id_rod != aa.id -- определили модель
                  and aaa.id_rod = aa.id -- определили модификацию
                  and trim(upper(mar.name)) = trim(upper(a.naimenovanie)) -- марки совпали
                  and mar.t_vehicle_mark_id = mm.t_vehicle_mark_id
                  and trim(upper(mm.name)) =  trim(upper(aa.naimenovanie)) -- модели совпали
                  and not exists (select 1 -- но моделей нет
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
                  and  upper(a.naimenovanie)!='НЕОПРЕДЕЛЕННОЕ ТРАНСПОРТНОЕ СРЕДСТВО' 
                   
               )
  loop
   insert into ven_t_model
   (t_vehicle_mark_id,name,power,t_main_model_id)
   values
   (modif.t_vehicle_mark_id,modif.naimenovanie,modif.moschnostls,modif.t_main_model_id);
  end loop;             

end insert_avto;
/


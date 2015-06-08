create or replace function quest_cmo_get_calendar_string
   (p_schedule_id number,
    p_frequency_type_code varchar2,
    p_interval varchar2,
    p_run_window_begin timestamp with  time zone
   )
   return varchar2
is
   calendar_string varchar2(500);
   s_freq varchar2 (10);
   byday_string varchar2(200);
   day_of_month_string varchar2(200);
begin
   if p_frequency_type_code is null then
      return null;
   end if;
   case
      when  p_frequency_type_code = 'DAY-FIXED' then
         s_freq := 'DAILY';
      when p_frequency_type_code = 'WEEK-FIXED' then
         s_freq := 'WEEKLY';
      when p_frequency_type_code = 'WEEK-DOW' then
         s_freq := 'WEEKLY';
         for c in (select
                      decode (day_of_week,7,'SUN',1,'MON',2,'TUE',
                                 3,'WED',4,'THU',5,'FRI',6,'SAT'
                             ) as day_of_week_str
                   from quest_cmo_schedule_run_days r
                   where r.schedule_id = p_schedule_id)
         loop
            byday_string := byday_string || c.day_of_week_str || ',';
         end loop;

         byday_string := SubStr(byday_string,1,Length(byday_string) - 1) ; --remove last comma

      when p_frequency_type_code = 'MONTH-FIXED' then
         s_freq := 'MONTHLY';
      when p_frequency_type_code = 'MONTH-DOW' then
         s_freq := 'MONTHLY';
         for c in (select to_char(week_of_month)
                              || decode (day_of_week,7,'SUN',1,'MON',2,'TUE',
                                            3,'WED',4,'THU',5,'FRI',6,'SAT'
                                        )
                             as day_of_week_month_str
                   from quest_cmo_schedule_run_days r
                   where r.schedule_id = p_schedule_id)
         loop
            byday_string := byday_string ||c.day_of_week_month_str || ',';
         end loop;
            byday_string := SubStr(byday_string,1,Length(byday_string) - 1); --remove last comma
      when  p_frequency_type_code = 'MONTH-DTOM' THEN
         s_freq := 'MONTHLY';
         for c in (select decode(day_of_month ,32,-1,day_of_month) day_of_month
                     from  quest_cmo_schedule_run_days r
                   where r.schedule_id = p_schedule_id)
         loop
            day_of_month_string := day_of_month_string
                                   || to_char(c.day_of_month) || ',';
         end loop;
            day_of_month_string := SubStr(day_of_month_string,
                                          1,Length(day_of_month_string) - 1) ; --remove last comma
      when p_frequency_type_code in ('MONTH_WKDAY','MONTH_WKEND') then
           s_freq := 'MONTHLY';
          for c in (select decode(day_of_month,32,-1,1,1) day_position
                  from  quest_cmo_schedule_run_days r
                   where r.schedule_id = p_schedule_id)
          loop
             if p_interval = 'MONTH_WKDAY' then
                byday_string := byday_string || 'BYDAY=MON,TUE,WED,THU,FRI;' ||
                                   'BYSETPOS = ' || to_char(c.day_position);
             else
                byday_string := byday_string || 'BYDAY=SAT,SUN;' ||
                                   'BYSETPOS = ' || to_char(c.day_position);
             end if;
          end loop;
      when p_frequency_type_code is null then null;
      else
         raise_application_error(-20002,
            'Unknown schedule frequency type ''' || p_frequency_type_code||'.');
   end case;
   calendar_string := 'FREQ='||s_freq||';';
   if byday_string is not null then
      calendar_string := calendar_string || 'BYDAY=' || byday_string || ';';
   end if;
   if day_of_month_string is not null then
      calendar_string := calendar_string ||'BYMONTHDAY='||day_of_month_string||';';
   end if;
   calendar_string := calendar_string ||
      'BYHOUR=' || to_char(p_run_window_begin,'HH24') || ';'
      || 'BYMINUTE=' || to_char(p_run_window_begin,'MI') || ';'
      || 'INTERVAL=' || to_char(p_interval);

   return calendar_string;
end quest_cmo_get_calendar_string ;
/


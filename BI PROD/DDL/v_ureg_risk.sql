create or replace force view v_ureg_risk as
select pl.description
     from t_prod_line_option pl
     where pl.description in ('Защита страховых взносов','Защита страховых взносов рассчитанная по основной программе',
                           'Освобождение от уплаты взносов рассчитанное по основной программе','Освобождение от уплаты дальнейших взносов',
                           'Освобождение от уплаты дальнейших взносов рассчитанное по основной программе',
                           'Освобождение от уплаты страховых взносов')
     union
     select tp.description
     from t_peril tp;


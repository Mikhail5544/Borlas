create or replace force view v_rsa_osago_tariff_t1 as
select
    ph.policy_header_id as s_ph,
    p.policy_id as s_p,
    pkg_contact.get_brief_contact_type_prior (a.contact_id) as s1, -- ��/�� ('��/��' ��� ����� �������)
-- ��� ��
/*
    1 �������� ���������� (������������ �������� ��������� "B")
	2 ������� � �������� �����������, ����������, ������������
	3 �����
	4 �������� ���������� (������������ �������� ��������� "C")
	        � ����������� ������������ ������ 16 ���� � �����
	5 �������� ���������� (������������ �������� ��������� "C")
	        � ����������� ������������ ������ ����� 16 ����
	6 ������� � �������� �����������, ���������, ����������
	       �������-������������ � ���� �������, �����������, �������-��������
	7 �������� (������������ �������� ��������� "D") � ������ ������������ ����
	     �� 20 ������������
	8 �������� (������������ �������� ��������� "D") � ������ ������������ ���� ����� 20
	9 �����������
	10 �������
	11 ��������, ���������� �������-������������ � ���� ������
	12 ��������� � ����������� (������������ �������� ��������� "A")
*/
 decode(vu.brief,'TAXI',3,
         decode(vt.brief,'TRUCK',  case  when (ve.max_weight>16000) then 5 else 4
        						   end,
                            'BUS', case  when (ve.passangers>20) then 8 else 7
             					   end,
							'CAR', 1,
							'CAR_TRAILER', 2,
							'TRUCK_TRAILER',6,'TRACTOR_TRAILER',6,'TRAILER',6,
							'TROLLEYBUS',9,
							'TRAM',10,
							'TRACTOR',11,
							'MOTORCYCLE',12)) as s2,
-- ����������, ������ ����������� ������ (�)
  case when vt.brief in ('TRACTOR','TRACTOR_TRAILER')
    then  case when cf.val = 1.2  then 1
	           when cf.val = 1  then -- �� ���� �����  2, 3 ��� 4
			                 -- 40 - ����� ���������
                             -- 46 - ���������� �������
                             -- 41 - ������������� �������
			         (select decode(substr(fn_get_ocatd(ca.adress_id),2),'40',2,'46',3,'41',4)
					 from cn_contact_address ca
					 where ca.id = ve.cn_contact_address_id and rownum = 1)
			   when cf.val = 0.8 then -- �� ������� 5 ��� 6
			       	(select pc.criteria_1 from t_prod_coef pc
					where pc.t_prod_coef_type_id = ct.t_prod_coef_type_id
					   and pc.val in (1.3, 1)  and pc.criteria_2 = 0 and rownum = 1)
	           when cf.val = 0.5  then 7
			   else 8
		   end
    else decode(cf.val,2,1,   1.8,2,   1.7,3,   1.6,4,   1.3,5,   1,6,   0.5,7,  8)
  end as s3,
-- ����������� ��������� ������� � ����������� �� �������� ��������� (��)
  case when vt.brief = 'CAR'  -- ������ ��� �������� ����������� (� �������� ����������� �����)
       then  case when cf2.val >= 1.7 then 6
                  when cf2.val in (0.5, 0.7, 1, 1.3, 1.5 ) then decode(cf2.val,0.5,1,   0.7,2,   1.0,3,   1.3,4,   1.5,5)
                  else 8 -- �.�. - ��� ������
              end
       else 0 --  � ������ ���� ��� �� �������� ����������
  end  as  s4,
-- ����������, ���
    decode(ph.policy_id,p.policy_id,
	           round(months_between(
               case when to_date('30.06.2007','dd.mm.yyyy') < p.end_date
        	         then to_date('30.06.2007','dd.mm.yyyy')
        			 else p.end_date end
        	   ,ph.start_date)/12,2),
			0) as s5,
-- ��������� �������
   (select  sum(pkg_claim_payment.get_claim_pay_sum_per(cc.c_claim_id,
                           to_date('01.07.2003','dd.mm.yyyy'), to_date('30.06.2008','dd.mm.yyyy')))
    from c_claim_header ch,  c_claim cc
	where ch.p_policy_id = p.policy_id
	  and cc.c_claim_header_id = ch.c_claim_header_id) as s6,
-- ���������� ���������� ������� (c_eventov)
   (select count(distinct ch.c_event_id)
    from c_claim_header ch, c_event e1
	where ch.p_policy_id = p.policy_id
	      and e1.c_event_id=ch.c_event_id
		  and e1.event_date between to_date('01.07.2003','dd.mm.yyyy')
		                         and to_date('30.06.2009','dd.mm.yyyy')) as s7,
-- ���������� ���������� ��������� �������
   (select count(distinct ch.c_event_id)
    from c_claim_header ch,  c_claim cc
	where ch.p_policy_id = p.policy_id
	  and cc.c_claim_header_id = ch.c_claim_header_id
	  and nvl(pkg_claim_payment.get_claim_pay_sum_per(cc.c_claim_id,to_date('01.07.2003','dd.mm.yyyy'),
	                                                to_date('30.06.2008','dd.mm.yyyy')),0) <> 0) as s8,
--------------------------------------------
----- � � � � � � � �
-- ��������� �������
   (select  sum(pkg_claim_payment.get_claim_pay_sum_per(cc.c_claim_id,
                           to_date('01.07.2003','dd.mm.yyyy'), to_date('30.06.2008','dd.mm.yyyy')))
    from c_claim_header ch,  c_claim cc
	where ch.p_policy_id = p.policy_id
	  and cc.c_claim_header_id = ch.c_claim_header_id
	  and exists (select 1 from  c_damage cd, t_damage_code dc, t_peril pr
	              where cd.c_claim_id = cc.c_claim_id
	                and cd.t_damage_code_id = dc.id
					and pr.id = dc.peril and pr.brief = '�����_��������')
	)as s9,
-- ���������� ���������� ������� (c_eventov)
   (select count(distinct ch.c_event_id)
    from c_claim_header ch,  c_claim cc, c_event e1
	where ch.p_policy_id = p.policy_id
	  and cc.c_claim_header_id = ch.c_claim_header_id
	  and e1.c_event_id = ch.c_event_id
	  and e1.event_date between to_date('01.07.2003','dd.mm.yyyy')
		                         and to_date('30.06.2009','dd.mm.yyyy')
	  and exists (select 1 from  c_damage cd, t_damage_code dc, t_peril pr
	              where cd.c_claim_id = cc.c_claim_id
	                and cd.t_damage_code_id = dc.id
					and pr.id = dc.peril and pr.brief = '�����_��������')
	) as s10,
   (select count(distinct ch.c_event_id)
    from c_claim_header ch,  c_claim cc
	where ch.p_policy_id = p.policy_id
	  and cc.c_claim_header_id = ch.c_claim_header_id
	  and exists (select 1 from  c_damage cd, t_damage_code dc, t_peril pr
	              where cd.c_claim_id = cc.c_claim_id
	                and cd.t_damage_code_id = dc.id
					and pr.id = dc.peril and pr.brief = '�����_��������')
	  and nvl(pkg_claim_payment.get_claim_pay_sum_per(cc.c_claim_id,to_date('01.07.2003','dd.mm.yyyy'),to_date('30.06.2008','dd.mm.yyyy')),0) <> 0
   ) as s11
 from
   p_policy p,
   p_pol_header ph,
   t_product prod,
   as_asset a,
   as_vehicle ve,
   t_vehicle_type vt,
   t_vehicle_usage vu,
   p_cover c,
   p_cover_coef cf,
   t_prod_coef_type ct,
   p_cover_coef cf2,
   t_prod_coef_type ct2,
   p_cover_coef cf3,
   t_prod_coef_type ct3
 where p.pol_header_id = ph.policy_header_id
    and p.confirm_date between to_date('01.07.2003','dd.mm.yyyy') and to_date('30.06.2009','dd.mm.yyyy')
    -- ����� ������ �������������� �������
	and doc.get_last_doc_status_brief(pkg_policy.get_last_version(ph.policy_header_id)) <> 'BREAK'
    -- ���� �������� ����� ����
	and round(months_between(p.end_date , ph.start_date)) = 12
    and ph.product_id = prod.product_id and prod.brief = '�����'
    and a.p_policy_id = p.policy_id
    and ve.as_vehicle_id = a.as_asset_id  and ve.is_foreing_reg = 0 and ve.is_to_reg = 0
    and vt.t_vehicle_type_id = ve.t_vehicle_type_id
    and vu.t_vehicle_usage_id(+) = ve.t_vehicle_usage_id
    and c.as_asset_id = a.as_asset_id
    and cf.p_cover_id = c.p_cover_id
    and ct.t_prod_coef_type_id = cf.t_prod_coef_type_id and ct.brief = 'OSAGO_AREA'
    and cf2.p_cover_id = c.p_cover_id
    and ct2.t_prod_coef_type_id = cf2.t_prod_coef_type_id and ct2.brief = 'OSAGO_POWER_HP'
    -- ������ ������������� ����� ����
	and cf3.p_cover_id = c.p_cover_id and cf3.val = 1.00
    and ct3.t_prod_coef_type_id = cf3.t_prod_coef_type_id and ct3.brief = 'OSAGO_PERIOD_OF_USE'
union all
    -- �������� ��� ���� ����� ����� �� ��������� �� �����
    select  0 as s_ph,0 as s_p,'��/��' as s1,
	      q1.l as s2 , q2.l as s3 , decode(q1.l,1,q3.l,3,q3.l,0) as s4,
	      0 as s5, 0 as s6,0 as s7,0 as s8, 0 as s9,0 as s10,0 as s11
    from (select l  from (select level l from dual connect by 1 = 1)
          where rownum < 13) q1,
          (select l from (select level l from dual connect by 1 = 1)
           where rownum < 9) q2,
          (select l from (select level l from dual connect by 1 = 1)
           where rownum <8) q3
;


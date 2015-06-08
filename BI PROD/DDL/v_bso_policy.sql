CREATE OR REPLACE FORCE VIEW V_BSO_POLICY AS
select
       bt.name "Тип БСО",
       b.num "Номер БСО",
       a.pol_ser "Серия ДС",
       a.pol_num "Номер ДС",
       a.notice_num "Номер заявления",
       a.ins_name "Страхователь",
       a.agent_name "Агент по ДС",
       c.obj_name_orig "Держатель БСО",
       dep.name        "Регион"
  from
       contact         c,
       bso             b,
       bso_hist        bh,
       bso_type        bt,
       bso_series      bs,
       department      dep,
       (select p.pol_header_id,
               p.pol_ser,
               p.pol_num,
               p.notice_num,
               c1.obj_name_orig ins_name,
               c2.obj_name_orig agent_name
          from  p_policy p,
                contact  c1,
                p_policy_agent pa,
                ag_contract_header ach,
                contact  c2
         where c1.contact_id = pkg_policy.get_policy_contact(p.policy_id, 'Страхователь')
           and pa.policy_header_id = p.pol_header_id
           and ach.ag_contract_header_id = pa.ag_contract_header_id
           and pa.status_id = 1
           and c2.contact_id = ach.agent_id
       )a
 where bs.bso_series_id = b.bso_series_id
   and bt.bso_type_id = bs.bso_type_id
   and bh.bso_hist_id = b.bso_hist_id
   and c.contact_id (+)= bh.contact_id
   and dep.department_id(+) = bh.department_id
   and a.pol_header_id (+) = b.pol_header_id
   and bt.name in (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'bso_pol' and param_name = 'bso_type')
order by bt.name, bh.num;


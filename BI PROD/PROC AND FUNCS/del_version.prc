CREATE OR REPLACE PROCEDURE del_version(par_p_policy_id in number) as
  -- процедура удаления версии ДС

  CURSOR c_trans (pp_policy_id in number) IS
select a.trans_id,a.trans_templ_id, b.*
  from (
SELECT t.trans_id,t.trans_templ_id, pc.t_prod_line_option_id--, pc.p_cover_id old_p_cover_id
  FROM trans t,
       p_policy pp,
       as_asset aa,
       p_cover pc
 WHERE pp.pol_header_id = pp.pol_header_id
   and aa.p_policy_id = pp.policy_id
   and pc.as_asset_id = aa.as_asset_id
   and ((t.obj_ure_id = 305 AND t.obj_uro_id = pc.p_cover_id)
   or (t.a1_dt_ure_id = 305 AND t.a1_dt_uro_id = pc.p_cover_id)
   or (t.a2_dt_ure_id = 305 AND t.a2_dt_uro_id = pc.p_cover_id)
   or (t.a3_dt_ure_id = 305 AND t.a3_dt_uro_id = pc.p_cover_id)
   or (t.a4_dt_ure_id = 305 AND t.a4_dt_uro_id = pc.p_cover_id)
   or (t.a5_dt_ure_id = 305 AND t.a5_dt_uro_id = pc.p_cover_id)
   or (t.a1_ct_ure_id = 305 AND t.a1_ct_uro_id = pc.p_cover_id)
   or (t.a2_ct_ure_id = 305 AND t.a2_ct_uro_id = pc.p_cover_id)
   or (t.a3_ct_ure_id = 305 AND t.a3_ct_uro_id = pc.p_cover_id)
   or (t.a4_ct_ure_id = 305 AND t.a4_ct_uro_id = pc.p_cover_id)
   or (t.a5_ct_ure_id = 305 AND t.a5_ct_uro_id = pc.p_cover_id))
   and t.trans_templ_id not in (67,623,57,581)--В этих Проводках аналитики плохо обрабатывать автоматически
   and pp.policy_id = pp_policy_id
       )a,
       (select p.policy_id prev_policy_id, aa.as_asset_id, pc.t_prod_line_option_id,pc.p_cover_id
          from p_policy p,--предыдущая версия
               p_policy p2,--удаляемая версия
               as_asset aa,
               p_cover  pc
         where p.pol_header_id = p2.pol_header_id
           and p.version_num = p2.version_num - 1
           and aa.p_policy_id = p.policy_id
           and pc.as_asset_id = aa.as_asset_id
           and p2.policy_id = pp_policy_id
       )b
 where b.t_prod_line_option_id = a.t_prod_line_option_id;

CURSOR c_PP (pp_policy_id in number) IS
select dso.doc_set_off_id -- dso к ПП от ЭПГ
  from doc_doc      dd,
       doc_set_off  dso,
       document     d,
       doc_templ    dt
 where dd.parent_id = pp_policy_id
   and dso.parent_doc_id = dd.child_id
   and d.document_id = dso.child_doc_id
   and dt.doc_templ_id = d.doc_templ_id
   and dt.brief = 'ПП';

CURSOR c_dso (pp_policy_id in number) IS --dso у ПП(от копии А7) и ПД4/А7
select dso2.doc_set_off_id,
       d2.document_id
  from doc_doc      dd,
       doc_set_off  dso,
       doc_doc      dd2,
       document     da7copy,
       doc_templ    dt,
       doc_set_off  dso2,
       document     d2,
       doc_templ    dt2
 where dd.parent_id = pp_policy_id
   and dso.parent_doc_id = dd.child_id
   and dd2.parent_id = dso.child_doc_id
    and d2.document_id = dso.child_doc_id
    and dt2.doc_templ_id = d2.doc_templ_id
    and dt2.brief in ('PD4','A7')
   and da7copy.document_id = dd2.child_id
   and dt.doc_templ_id = da7copy.doc_templ_id
   and dt.brief = 'A7COPY'
   and dso2.parent_doc_id = da7copy.document_id;

r  c_trans%ROWTYPE;
rpp  c_pp%ROWTYPE;
rdso  c_dso%ROWTYPE;
v_prev_policy_id number;
--par_p_policy_id  number:=11990911; --Удаляемая версия ДС

--select ent.obj_name('CONTACT',pkg_policy.get_policy_contact(p.policy_id, 'Страхователь')), p.* from p_policy p where p.pol_num = '035401'

BEGIN
select p.policy_id
  into v_prev_policy_id
  from p_policy p,
       p_policy p2
 where p.pol_header_id = p2.pol_header_id
   and p2.policy_id = par_p_policy_id
   and p.version_num = p2.version_num - 1;

--Аннулирование платежей
--dso к ПП
for rpp in c_pp(par_p_policy_id) loop
update ven_doc_set_off set cancel_date = doc.get_last_doc_status_date(rpp.doc_set_off_id)+1/24/3600
 where doc_set_off_id = rpp.doc_set_off_id;
doc.set_doc_status(p_doc_id => rpp.doc_set_off_id, p_status_brief => 'ANNULATED',
                   p_status_date => doc.get_last_doc_status_date(rpp.doc_set_off_id)+1/24/3600);
end loop;
for rdso in c_dso(par_p_policy_id) loop
--dso к ПП от копии А7
update ven_doc_set_off set cancel_date = doc.get_last_doc_status_date(rdso.doc_set_off_id)+1/24/3600
 where doc_set_off_id = rdso.doc_set_off_id;
doc.set_doc_status(p_doc_id => rdso.doc_set_off_id, p_status_brief => 'ANNULATED',
                   p_status_date => doc.get_last_doc_status_date(rdso.doc_set_off_id)+1/24/3600);
----ПД4/А7
update ven_doc_set_off set cancel_date = doc.get_last_doc_status_date(rdso.document_id)+1/24/3600
 where doc_set_off_id = rdso.document_id;
doc.set_doc_status(p_doc_id => rdso.document_id, p_status_brief => 'ANNULATED',
                   p_status_date => doc.get_last_doc_status_date(rdso.document_id)+1/24/3600);
end loop;

--Перевод в проект
doc.set_doc_status(par_p_policy_id,'NEW'    ,sysdate);
doc.set_doc_status(par_p_policy_id,'PROJECT',sysdate+1/24/3600);
commit;
   FOR r in c_trans (par_p_policy_id) LOOP
--Update аналитик с obj_ure 283 (Версия договора страхования) и 305 (Страховое покрытие)
    if r.trans_templ_id <> 42 then
       update trans t set t.a2_ct_uro_id = r.prev_policy_id,
                          t.a2_ct_ure_id = 283,
                          t.a2_dt_uro_id = r.prev_policy_id,
                          t.a2_dt_ure_id = 283,
                          t.a5_ct_uro_id = r.p_cover_id,
                          t.a5_ct_ure_id = 305,
                          t.a5_dt_uro_id = r.p_cover_id,
                          t.a5_dt_ure_id = 305,
                          t.obj_uro_id   = r.p_cover_id,
                          t.obj_ure_id   = 305
       where t.trans_id = r.trans_id;
       commit;
    elsif r.trans_templ_id = 42 then
       update trans t set t.a5_ct_uro_id = r.p_cover_id,
                          t.a5_ct_ure_id = 305
       where t.trans_id = r.trans_id;
       commit;
    end if;
    END LOOP;
--2-Перекинуть ЭПГ

update doc_doc dd set dd.parent_id = v_prev_policy_id where dd.parent_id = par_p_policy_id;
--3-Update oper, смотрящих на версию
update oper o set o.document_id = v_prev_policy_id where o.document_id = par_p_policy_id;
commit;
--Удалить версию
doc.set_doc_status(par_p_policy_id,'CANCEL' ,sysdate+2/24/3600);
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20001, 'Ошибка при выполнении'||SQLERRM);

ENd del_version;
/


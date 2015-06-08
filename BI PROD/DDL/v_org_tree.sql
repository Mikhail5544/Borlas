CREATE OR REPLACE VIEW V_ORG_TREE AS
SELECT ort.organisation_tree_id,ort.ent_id,ort.filial_id,ort.parent_id,ort.name,ort.company_id,ort.ext_id,ort.code,ort.brief,
         ort.province_id,ort.city_id, ort.tac_id,                                                                                                     
        c.obj_name_orig company_name,
        ort2.name parent_name,
        p.province_name,
        tac.tac_name, 
        ort.reg_code,
        ort.L,
        p.code province_code
   FROM contact c, 
        organisation_tree ort2, 
        (select kl.code, kl.name province_name
        from ins.t_kladr kl,
             ins.t_socrbase ors
        where kl.socr = ors.scname
          and ors.plevel = 1
          and kl.code LIKE '__000000000__') p,
        ven_agn_tac tac,
         (SELECT ort.*, level as "L"
            FROM organisation_tree ort
           START WITH ort.parent_id IS NULL
         CONNECT BY PRIOR ort.organisation_tree_id = ort.parent_id
           ORDER SIBLINGS BY ort.name) ort
WHERE c.contact_id = ort.company_id
  and ort2.organisation_tree_id (+) = ort.parent_id
  and ort.province_code = p.code(+)
  and tac.agn_tac_id (+) = ort.tac_id;

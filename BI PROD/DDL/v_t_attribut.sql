create or replace force view v_t_attribut as
select a.t_attribut_id as t_attribut_id,
       a.ent_id,
       a.name             attr_name,
       a.brief            attr_brief,
       a.attribut_ent_id  attribut_ent_id,
       a.obj_list_sql     obj_list_sql,
       e.ent_id           ent_ent_id,
       e.parent_id        ent_parent_id,
       e.name             ent_name,
       e.brief            ent_brief,
       e.source           ent_source,
       A.T_ATTRIBUT_SOURCE_ID T_ATTRIBUT_SOURCE_ID,
       S.NAME             S_NAME,
       S.BRIEF            S_BRIEF,
       A.ATTR_TARIF_ID    ATTR_TARIF_ID,
       P.NAME             TARIFF_NAME,
       P.BRIEF            TARIFF_BRIEF,
	   A.Note             NOTE       
from t_attribut a, entity e, T_ATTRIBUT_SOURCE S, T_PROD_COEF_TYPE P
where a.attribut_ent_id=e.ent_id(+)
  AND A.T_ATTRIBUT_SOURCE_ID=S.T_ATTRIBUT_SOURCE_ID
  AND P.T_PROD_COEF_TYPE_ID(+)=A.ATTR_TARIF_ID;


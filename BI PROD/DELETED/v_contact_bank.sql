-- SELECT * FROM v_contact_bank_list WHERE city_name = 'Москва'
CREATE OR REPLACE VIEW v_contact_bank_list AS
SELECT  c.obj_name_orig,
        ( SELECT  cci.id_value
            FROM  ven_cn_contact_ident cci   
            WHERE cci.contact_id = c.contact_id 
              AND cci.country_id = 
                    ( SELECT  id 
                        FROM  t_country 
                        WHERE description = 'Россия' )
              AND cci.id_type = 
                    ( SELECT  id 
                        FROM  t_id_type 
                        WHERE brief = 'BIK' ) 
              AND rownum = 1 ) bic,
        ( SELECT  cci.id_value
            FROM  ven_cn_contact_ident cci   
            WHERE cci.contact_id = c.contact_id 
              AND cci.country_id = 
                    ( SELECT  id 
                        FROM  t_country 
                        WHERE description = 'Россия' )
              AND cci.id_type = 
                    ( SELECT  id 
                        FROM  t_id_type 
                        WHERE brief = 'KORR' ) 
              AND rownum = 1 ) corracc,
        ( SELECT  cci.id_value
            FROM  ven_cn_contact_ident cci   
            WHERE cci.contact_id = c.contact_id 
              AND cci.country_id = 
                    ( SELECT  id 
                        FROM  t_country 
                        WHERE description = 'Россия' )
              AND cci.id_type = 
                    ( SELECT  id 
                        FROM  t_id_type 
                        WHERE brief = 'INN' ) 
              AND rownum = 1 ) inn,      
        q_country.country_id,
        q_country.country_name,
        q_city.city_id,
        q_city.city_name,
        c.contact_id      
  FROM  contact c,
        ( SELECT  cca.contact_id, ca.country_id,
                  co.description country_name
            FROM  cn_contact_address cca,
                  cn_address         ca,
                  t_country          co
            WHERE cca.is_default = 1
              AND cca.adress_id = ca.id
              AND ca.country_id = co.id ) q_country, 
        ( SELECT  cca.contact_id, 
                  DECODE( ca.province_name, 'Москва', 0,
                    'Санкт-Петербург', ( -1 ), 
                    ( SELECT ca.city_id FROM t_city ci WHERE ca.city_id = ci.city_id ) ) city_id, 
                  DECODE( ca.province_name, 'Москва', 'Москва', 
                    'Санкт-Петербург', 'Санкт-Петербург', 
                    ( SELECT ca.city_name FROM t_city ci WHERE ca.city_id = ci.city_id ) ) city_name
            FROM  cn_contact_address cca,
                  cn_address         ca
            WHERE cca.is_default = 1
              AND cca.adress_id = ca.id ) q_city
  WHERE c.contact_id = q_country.contact_id(+)
    AND c.contact_id = q_city.contact_id(+)
    AND EXISTS ( SELECT  '1'
                   FROM  cn_contact_role cr,
                         t_contact_role  tcr
                   WHERE cr.contact_id = c.contact_id
                     AND cr.role_id = tcr.id
                     AND tcr.description = 'Банк' )
/


CREATE OR REPLACE VIEW V_CRM_CONTACT_DETAIL AS
SELECT contact_id
      ,type -- нумерация согласно t_message_type_props
      ,kind -- нумерация согласно http://redmine.renlife.com/issues/1313
      ,type_id
      ,type_brief
      ,country_id
      ,description
      ,dat
FROM (SELECT ct.contact_id
            ,2 type
            ,1 sort_type
            ,CASE WHEN tt.description LIKE 'Мобильный%'        THEN 1
                  WHEN tt.description LIKE 'Домашний телефон%' THEN 2
                  WHEN tt.description LIKE 'Рабочий телефон%'  THEN 3
                  WHEN tt.description LIKE 'Факс%'             THEN 4
                  WHEN tt.description LIKE 'Неверный телефон%' THEN 5
                  ELSE 6
             END kind
            ,ct.id    type_id
            ,tt.brief type_brief
            ,ct.country_id
            ,tt.description
            ,ct.telephone_number dat
      FROM cn_contact_telephone ct
          ,t_telephone_type     tt
      WHERE 1 = 1
        AND ct.telephone_type = tt.id
      UNION
      SELECT ce.contact_id
            ,3 type
            ,3 sort_type
            ,CASE WHEN et.description LIKE 'Адрес ЛК%'       THEN 1
                  WHEN et.description LIKE 'Личный%'         THEN 2
                  WHEN et.description LIKE 'Адрес рассылки%' THEN 3
                  WHEN et.description LIKE 'Рабочий%'        THEN 4
                  ELSE 5
             END kind
            ,ce.id    type_id
            ,null     type_brief
            ,null     country_id
            ,et.description
            ,ce.email dat
      FROM cn_contact_email ce
          ,t_email_type     et
      WHERE 1 = 1
        AND ce.email_type = et.id
      UNION
      SELECT ca.contact_id
            ,1 type
            ,2 sort_type
            ,CASE WHEN at.description LIKE 'Адрес фактического нахождения%' THEN 1
                  WHEN at.description LIKE 'Адрес постоянной регистрации%'  THEN 2
                  WHEN at.description LIKE 'Почтовый адрес%'                THEN 3
                  WHEN at.description LIKE 'Юридический адрес%'             THEN 4
                  WHEN at.description LIKE 'Домашний адрес%'                THEN 5
                  WHEN at.description LIKE 'Адрес временной регистрации%'   THEN 6
                  ELSE 7
             END kind
            ,ca.id    type_id
            ,at.brief type_brief
            ,a.country_id
            ,at.description
            ,a.name dat
      FROM cn_contact_address ca
          ,t_address_type     at
          ,cn_address         a
      WHERE 1 = 1
        AND ca.address_type = at.id
        AND ca.adress_id    = a.id)
WHERE trim(dat) IS NOT NULL
ORDER BY sort_type, kind, description;
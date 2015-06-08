CREATE OR REPLACE PACKAGE pkg_contact_fmb IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 25.06.2014 12:56:58
  -- Purpose : Логика формы CONTACT.FMB

  FUNCTION check_profile_address(par_contact_id contact.contact_id%TYPE) RETURN BOOLEAN;
  FUNCTION check_profile_doc(par_contact_id contact.contact_id%TYPE) RETURN BOOLEAN;
  FUNCTION check_profile_name
  (
    par_contact_id  contact.contact_id%TYPE
   ,par_name        contact.name%TYPE
   ,par_first_name  contact.first_name%TYPE
   ,par_middle_name contact.middle_name%TYPE
  ) RETURN BOOLEAN;
  FUNCTION check_profile_public
  (
    par_contact_id        contact.contact_id%TYPE
   ,par_is_public_contact contact.is_public_contact%TYPE
   ,par_is_in_list        cn_person.is_in_list%TYPE
  ) RETURN BOOLEAN;

  PROCEDURE get_max_document
  (
    par_contact_id    contact.contact_id%TYPE
   ,par_doc_type_name OUT t_id_type.description%TYPE
   ,par_series        OUT cn_contact_ident.serial_nr%TYPE
   ,par_number        OUT cn_contact_ident.id_value%TYPE
  );

  FUNCTION get_max_profile_address(par_contact_id contact.contact_id%TYPE)
    RETURN cn_profile_address.address%TYPE;

END pkg_contact_fmb;
/
CREATE OR REPLACE PACKAGE BODY pkg_contact_fmb IS

  FUNCTION check_profile_address(par_contact_id contact.contact_id%TYPE) RETURN BOOLEAN IS
    v_is_exists NUMBER(1);
  BEGIN
  
    SELECT COUNT(1)
      INTO v_is_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM cn_profile_address cp
                  ,cn_contact_address ci
                  ,cn_address         ca
             WHERE ci.contact_id = par_contact_id
               AND cp.contact_id = ci.contact_id
               AND ci.adress_id = ca.id
               AND ca.name = cp.address)
        OR NOT EXISTS
     (SELECT NULL FROM cn_profile_address cp WHERE cp.contact_id = par_contact_id)
        OR NOT EXISTS (SELECT NULL
              FROM cn_contact_address ci
                  ,cn_address         ca
             WHERE ci.contact_id = par_contact_id
               AND ci.adress_id = ca.id);
  
    RETURN v_is_exists = 1;
  END check_profile_address;

  FUNCTION check_profile_doc(par_contact_id contact.contact_id%TYPE) RETURN BOOLEAN IS
    v_is_exists NUMBER(1);
  BEGIN
  
    SELECT COUNT(1)
      INTO v_is_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM cn_profile_doc   cp
                  ,cn_contact_ident ci
                  ,t_id_type        it
             WHERE ci.contact_id = par_contact_id
               AND cp.contact_id = ci.contact_id
               AND cp.t_id_type_id = ci.id_type
               AND cp.doc_series = ci.serial_nr
               AND cp.doc_number = ci.id_value
               AND ci.id_type = it.id
               AND it.brief IN ('PASS_RF', 'BIRTH_CERT', 'PASS_IN'))
        OR NOT EXISTS (SELECT NULL FROM cn_profile_doc cp WHERE cp.contact_id = par_contact_id)
        OR NOT EXISTS (SELECT NULL
              FROM cn_contact_ident ci
                  ,t_id_type        it
             WHERE ci.contact_id = par_contact_id
               AND ci.id_type = it.id
               AND it.brief IN ('PASS_RF', 'BIRTH_CERT', 'PASS_IN'));
  
    RETURN v_is_exists = 1;
  END check_profile_doc;

  FUNCTION check_profile_name
  (
    par_contact_id  contact.contact_id%TYPE
   ,par_name        contact.name%TYPE
   ,par_first_name  contact.first_name%TYPE
   ,par_middle_name contact.middle_name%TYPE
  ) RETURN BOOLEAN IS
    v_is_exists NUMBER(1);
  BEGIN
    SELECT COUNT(1)
      INTO v_is_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM cn_profile_name pn
             WHERE (upper(pn.last_name) != upper(par_name) OR
                   upper(pn.first_name) != upper(par_first_name) OR
                   upper(pn.middle_name) != upper(par_middle_name))
               AND pn.contact_id = par_contact_id);
    RETURN v_is_exists = 1;
  END check_profile_name;

  FUNCTION check_profile_public
  (
    par_contact_id        contact.contact_id%TYPE
   ,par_is_public_contact contact.is_public_contact%TYPE
   ,par_is_in_list        cn_person.is_in_list%TYPE
  ) RETURN BOOLEAN IS
    v_is_exists NUMBER(1);
  BEGIN
    SELECT COUNT(1)
      INTO v_is_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM cn_profile_public pn
             WHERE (is_foreign_public_contact != par_is_public_contact OR
                   is_russian_public_contact != par_is_in_list)
               AND pn.contact_id = par_contact_id);
    RETURN v_is_exists = 1;
  END check_profile_public;

  PROCEDURE get_max_document
  (
    par_contact_id    contact.contact_id%TYPE
   ,par_doc_type_name OUT t_id_type.description%TYPE
   ,par_series        OUT cn_contact_ident.serial_nr%TYPE
   ,par_number        OUT cn_contact_ident.id_value%TYPE
  ) IS
  BEGIN
    SELECT it.description
          ,ci.id_value
          ,ci.serial_nr
      INTO par_doc_type_name
          ,par_number
          ,par_series
      FROM cn_contact_ident ci
          ,t_id_type        it
     WHERE ci.id_type = it.id
       AND ci.table_id IN (SELECT MAX(cim.table_id)
                             FROM cn_contact_ident cim
                                 ,t_id_type        itm
                            WHERE cim.contact_id = par_contact_id
                              AND cim.id_type = itm.id
                              AND itm.brief IN ('PASS_RF', 'BIRTH_CERT', 'PASS_IN'));
  
  END get_max_document;

  FUNCTION get_max_profile_address(par_contact_id contact.contact_id%TYPE)
    RETURN cn_profile_address.address%TYPE IS
    v_address cn_profile_address.address%TYPE;
  BEGIN
    SELECT pa.address
      INTO v_address
      FROM cn_profile_address pa
     WHERE pa.cn_profile_address_id IN
           (SELECT MAX(pa.cn_profile_address_id)
              FROM cn_profile_address pa
             WHERE pa.contact_id = par_contact_id);
    RETURN v_address;
  
  END get_max_profile_address;

END pkg_contact_fmb;
/

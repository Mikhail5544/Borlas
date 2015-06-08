CREATE OR REPLACE PACKAGE safety_ldap IS

  /**
  * Работа с каталогом пользователей Oracle Internet Directory
  * @author Patsan O.
  */

  /**
  * Создание пользователя OID
  * @author Patsan O.
  * @param p_user_name Системное имя пользователя
  * @param p_pwd Пароль
  */
  PROCEDURE create_user
  (
    p_user_name IN VARCHAR2
   ,p_pwd       IN VARCHAR2
  );

END safety_ldap;
/
CREATE OR REPLACE PACKAGE BODY safety_ldap IS

  ldap_host   VARCHAR2(255) := pkg_app_param.get_app_param_c('LDAP_HOST');
  ldap_port   VARCHAR2(255) := pkg_app_param.get_app_param_c('LDAP_PORT');
  ldap_user   VARCHAR2(255) := pkg_app_param.get_app_param_c('LDAP_USER');
  ldap_passwd VARCHAR2(255) := pkg_app_param.get_app_param_c('LDAP_PASSWD');
  ldap_domain VARCHAR2(255) := pkg_app_param.get_app_param_c('LDAP_DOMAIN');
  ldap_base   VARCHAR2(255) := 'cn=Users,' || ldap_domain;

  retval NUMBER;

  ldap_session DBMS_LDAP.SESSION := NULL;
  --  ldapDefaultSubscriberPath varchar2(2000) := '';

  frm_array DBMS_LDAP.MOD_ARRAY;
  frm_vals  DBMS_LDAP.STRING_COLLECTION;
  frm_dn    VARCHAR2(2000);

  -- Internal RAD variables to store the definition of the Resource
  -- Access descriptor to create

  pRadName    VARCHAR2(100) := pkg_app_param.get_app_param_c('LDAP_RAD_NAME');
  pDbUsername VARCHAR2(100) := NULL;
  pDbPassword VARCHAR2(100) := NULL;
  pDbTNSname  VARCHAR2(100) := pkg_app_param.get_app_param_c('LDAP_RAD_DB');

  --hasValidRADdefinition boolean := false;
  hasActiveOidSession BOOLEAN := FALSE;

  rad_exception EXCEPTION;
  oidRadErrorMessage VARCHAR2(4000);

  FUNCTION create_session RETURN BOOLEAN IS
  BEGIN
    ldap_session := DBMS_LDAP.init(ldap_host, ldap_port);
    retval       := DBMS_LDAP.simple_bind_s(ldap_session, ldap_user, ldap_passwd);
  
    IF (retval = 1024)
    THEN
      DBMS_OUTPUT.PUT_LINE('OID недоступен');
    END IF;
  
    IF (retval <> DBMS_LDAP.SUCCESS)
    THEN
      DBMS_OUTPUT.PUT_LINE('Ошибка подключения к OID ' || retval);
      RETURN FALSE;
    ELSE
      --      ldapDefaultsubscriberPath := defaultSubscriberPath;
      hasActiveOidSession := TRUE;
      RETURN TRUE;
    END IF;
  
  END;

  FUNCTION createRADforCN
  (
    ldap_user_Cn   IN VARCHAR2
   ,userCanEditRAD IN VARCHAR2
  ) RETURN BOOLEAN IS
    guid        VARCHAR2(256); -- Unique global ID identifying the user in OID
    entry_dn    VARCHAR2(256);
    rad_dn_base VARCHAR2(256); --
    --  radModifiable varchar2(100) := userCanEditRAD; -- Can user modify RAD entries after creation ?
    frm_vals     DBMS_LDAP.STRING_COLLECTION;
    my_vals      DBMS_LDAP.STRING_COLLECTION;
    my_ber_elmt  DBMS_LDAP.ber_element;
    my_attrs     DBMS_LDAP.STRING_COLLECTION;
    my_attr_name VARCHAR2(256);
    my_message   DBMS_LDAP.message;
    my_entry     DBMS_LDAP.message;
    ret_val      PLS_INTEGER := -1;
  
    userDN VARCHAR2(2000) := 'cn=' || ldap_user_Cn || ',' || ldap_base;
  
  BEGIN
  
    -- Requires valid OID session  to execute
    /*
        if not (hasValidRADdefinition and hasActiveOidSession) then
    
          oidRadErrorMessage := 'ERROR: Please establish an OID session and define a ' ||
                                'valid RAD entry';
          raise rad_exception;
        end if;
    */
    my_attrs(1) := 'orclguid';
  
    -- search OID for entry
    ret_val := DBMS_LDAP.search_s(ldap_session
                                 ,userDN
                                 ,DBMS_LDAP.SCOPE_BASE
                                 ,'objectclass=*'
                                 ,my_attrs
                                 ,0
                                 ,my_message);
  
    IF ret_val <> DBMS_LDAP.SUCCESS
    THEN
      oidRadErrorMessage := 'Error in search expression when creating RAD entry. Cannot retrieve orclguid';
      RAISE rad_exception;
    END IF;
  
    my_entry     := DBMS_LDAP.first_entry(ldap_session, my_message);
    my_attr_name := DBMS_LDAP.first_attribute(ldap_session, my_entry, my_ber_elmt);
    my_vals      := DBMS_LDAP.get_values(ldap_session, my_entry, my_attr_name);
    guid         := my_vals(0);
  
    frm_array := DBMS_LDAP.create_mod_array(40);
    frm_vals(1) := 'top';
    frm_vals(2) := 'orclReferenceObject';
  
    DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'objectclass', frm_vals);
  
    frm_vals.DELETE;
    frm_vals(1) := guid;
    DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'orclownerguid', frm_vals);
  
    frm_vals(1) := userDN;
    DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'seealso', frm_vals);
  
    entry_dn := 'orclownerguid=' || guid || ',cn=Extended Properties,cn=OracleContext,' || ldap_domain;
  
    BEGIN
    
      IF ret_val <> DBMS_LDAP.ALREADY_EXISTS
         AND ret_val <> DBMS_LDAP.SUCCESS
      THEN
        oidRadErrorMessage := 'Could not create Extended Properties Container';
        RAISE rad_exception;
      END IF;
      ret_val := DBMS_LDAP.add_s(ldap_session, entry_dn, frm_array);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    DBMS_LDAP.FREE_MOD_ARRAY(frm_array);
  
    frm_array := DBMS_LDAP.create_mod_array(6);
    frm_vals(1) := 'top';
    frm_vals(2) := 'orclcontainer';
    frm_vals(3) := 'orclauxiliaryguid';
  
    DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'objectclass', frm_vals);
    frm_vals.DELETE;
    frm_vals(1) := guid;
    DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'orclownerguid', frm_vals);
  
    frm_vals(1) := 'Resource Access Descriptor';
    DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'cn', frm_vals);
  
    entry_dn    := 'cn=Resource Access Descriptor, ' || entry_dn;
    rad_dn_base := entry_dn;
  
    BEGIN
      ret_val := DBMS_LDAP.add_s(ldap_session, entry_dn, frm_array);
    
      IF (ret_val != DBMS_LDAP.ALREADY_EXISTS AND ret_val != DBMS_LDAP.SUCCESS)
      THEN
        oidRadErrorMessage := 'Could not create user Resource Access Descriptor Container';
        RAISE rad_exception;
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    DBMS_LDAP.FREE_MOD_ARRAY(frm_array);
  
    frm_array := DBMS_LDAP.create_mod_array(15);
  
    frm_vals(1) := 'OracleDb';
    DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'orclresourcetypename', frm_vals);
  
    frm_vals(1) := pDbTNSname;
    DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'orclflexattribute1', frm_vals);
    frm_vals(1) := pDbUsername;
    DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'orcluseridattribute', frm_vals);
    frm_vals(1) := guid;
    DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'orclownerguid', frm_vals);
    /* Ничего не делающий код  
    if ((radModifiable <> 'true') or (radModifiable <> 'TRUE')) then
      radModifiable := 'false';
    end if;*/
    frm_vals(1) := userCanEditRAD;
    DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'orclusermodifiable', frm_vals);
    frm_vals(1) := pDbPassword;
    DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'orclpasswordattribute', frm_vals);
    frm_vals(1) := pRadName;
    DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'orclresourcename', frm_vals);
  
    frm_vals(1) := 'top';
    frm_vals(2) := 'orclresourcedescriptor';
    DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'objectclass', frm_vals);
    frm_vals.DELETE;
  
    entry_dn := 'orclresourcename=' || pRadName || '+orclresourcetypename=oracleDB, ' || rad_dn_base;
  
    ret_val := DBMS_LDAP.add_s(ldap_session, entry_dn, frm_array);
    DBMS_LDAP.FREE_MOD_ARRAY(frm_array);
    IF (ret_val = DBMS_LDAP.ALREADY_EXISTS)
    THEN
      DBMS_OUTPUT.PUT_LINE('Debug ::: RAD entry ' || pRadName || ' already exists');
    END IF;
  
    IF ret_val <> DBMS_LDAP.ALREADY_EXISTS
       AND ret_val <> DBMS_LDAP.SUCCESS
    THEN
      RAISE rad_exception;
    END IF;
  
    RETURN TRUE;
  EXCEPTION
    -- Exceptions that are based on problems discovered in this PLSQL program
    WHEN rad_exception THEN
      --ErrorMsg := 'ERROR in OID communication: ' || oidRadErrorMessage;
      DBMS_OUTPUT.PUT_LINE('Debug ::: ERROR in OID communication: ' || oidRadErrorMessage);
      DBMS_LDAP.free_mod_array(frm_array);
      RETURN FALSE;
    
    WHEN OTHERS THEN
      --oidRadErrorMessage := 'Error in ' || loc;
      --ErrorMsg           := oidRadErrorMessage;
      DBMS_OUTPUT.PUT_LINE(oidRadErrorMessage);
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      DBMS_LDAP.free_mod_array(frm_array);
      RETURN FALSE;
  END;

  PROCEDURE create_user
  (
    p_user_name IN VARCHAR2
   ,p_pwd       IN VARCHAR2
  ) IS
  BEGIN
    IF NOT hasActiveOidSession
    THEN
      hasActiveOidSession := create_session;
    END IF;
    IF hasActiveOidSession
    THEN
      frm_array := DBMS_LDAP.create_mod_array(10);
      frm_vals(1) := p_user_name;
      DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'cn', frm_vals);
      DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'sn', frm_vals);
      DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'givenname', frm_vals);
      DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'mail', frm_vals);
      DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'uid', frm_vals);
      frm_vals(1) := 'top';
      frm_vals(2) := 'person';
      frm_vals(3) := 'organizationalPerson';
      frm_vals(4) := 'inetOrgPerson';
      frm_vals(5) := 'orclUserV2';
      DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'objectclass', frm_vals);
      frm_vals.DELETE;
      frm_vals(1) := 'ENABLED';
      DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'orclisenabled', frm_vals);
      frm_vals(1) := p_pwd;
      DBMS_LDAP.populate_mod_array(frm_array, DBMS_LDAP.MOD_ADD, 'userpassword', frm_vals);
    
      frm_dn := 'cn=' || p_user_name || ', ' || ldap_base;
      BEGIN
        retval := DBMS_LDAP.add_s(ldap_session, frm_dn, frm_array);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      DBMS_LDAP.free_mod_array(frm_array);
    
      pDbUsername := p_user_name;
      pDbPassword := p_pwd;
      IF createRADforCN(p_user_name, 'true')
      THEN
        NULL;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
  END;

  PROCEDURE delete_user(p_user_name IN VARCHAR2) IS
  BEGIN
    IF NOT hasActiveOidSession
    THEN
      hasActiveOidSession := create_session;
    END IF;
    IF hasActiveOidSession
    THEN
      frm_dn := 'cn=' || p_user_name || ', ' || ldap_base;
      retval := DBMS_LDAP.delete_s(ldap_session, frm_dn);
    END IF;
  END;

  PROCEDURE update_user
  (
    p_user_name IN VARCHAR2
   ,p_pwd       IN VARCHAR2
  ) IS
  BEGIN
    /*
    TODO: owner="skushenko" created="28.03.2008"
    text="Почему пусто?"
    */
    NULL;
  END;

BEGIN
  DBMS_LDAP.USE_EXCEPTION := TRUE;
END safety_ldap;
/

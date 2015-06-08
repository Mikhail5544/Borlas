CREATE OR REPLACE PACKAGE pkg_doc_move IS

  DME_DataNotFound        EXCEPTION; -- �� ������� ������ ��� ������
  DME_NotAllowedOperation EXCEPTION; -- �� ���������� �������� ��� ����������
  /**
  * �������� ���������� �������� ���������
  * @author Patsan O.
  * @param par_document_id �� ���������
  * @param par_departmant_id �� ������������
  * @param par_person_id �� ��������
  */
  PROCEDURE create_movement
  (
    par_document_id   IN NUMBER
   ,par_departmant_id IN NUMBER
   ,par_person_id     IN NUMBER
  );

  /**
  * �������� ���������� �������� ���������
  * @author Patsan O.
  * @param par_document_id �� ���������� ��������
  * @param par_departmant_id �� ������������
  * @param par_person_id �� ��������
  * @param par_note ���������� � ��������
  */
  PROCEDURE next_movement
  (
    par_doc_move_id   IN NUMBER
   ,par_departmant_id IN NUMBER
   ,par_person_id     IN NUMBER
   ,par_note          IN VARCHAR2
  );

  /**
  * ��������� �������� ���������
  * @author Patsan O.
  * @param par_doc_move_id �� ���������� ��������
  */
  FUNCTION stop_movement(par_doc_move_id IN NUMBER) RETURN NUMBER;

  /* �������� ��������� �� ������ ���������� � ������� 
  * @author Guryev A. 
  * @param par_document_id �� ���������� ��������
  * @param par_departmant_id �� ������������
  * @param par_person_id �� ��������
  * @param par_note ���������� � ��������
  */

  FUNCTION deliver
  (
    par_doc_move_id   IN NUMBER
   ,par_departmant_id IN NUMBER
   ,par_person_id     IN NUMBER
   ,par_note          IN VARCHAR2
  ) RETURN NUMBER;
  /* �������� ��������� 
  * @author Guryev A. 
  * @param par_document_id �� ���������� �������� 
  */
  FUNCTION close_movement(par_doc_move_id IN NUMBER) RETURN NUMBER;

  /* ������ �������� ��������� �� ������ ���������� � ������� 
  * @author Guryev A. 
  * @param par_document_id �� �������� 
  */
  FUNCTION cancel_deliver(par_doc_move_id IN NUMBER) RETURN NUMBER;

  /* ���������� �������� ��������� �� ������ ���������� � ������� 
  * @author Guryev A. 
  * @param par_document_id �� ������ ��������, ����������� ����������, ������� ���������
  * @param par_note ���������� � ����������
  */
  FUNCTION reject_movement
  (
    par_doc_move_id IN NUMBER
   ,par_note        IN VARCHAR2
  ) RETURN NUMBER;

  /* ������� �������� ��������� �� ������ ���������� � ������� 
  * @author Guryev A. 
  * @param par_document_id �� ������ ��������, ����������� ����������
  */
  FUNCTION accept_movement(par_doc_move_id IN NUMBER) RETURN NUMBER;

  /* ���������� ID ������� �������� �� brief
  * @author Guryev A.
  * @param par_brief brief ������� ��������
  */
  FUNCTION get_status(par_brief IN VARCHAR2) RETURN NUMBER;

END pkg_doc_move;
/
CREATE OR REPLACE PACKAGE BODY pkg_doc_move IS

  FUNCTION get_status(par_brief IN VARCHAR2) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT nvl(t_dm_status_id, 0) INTO RESULT FROM t_dm_status WHERE brief = upper(par_brief);
    RETURN RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    
  END;

  FUNCTION get_doc_templ(par_brief IN VARCHAR2) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT doc_templ_id INTO RESULT FROM doc_templ WHERE brief = par_brief;
    RETURN RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  FUNCTION get_dt_id(par_document_id IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT DISTINCT d.doc_templ_id
      INTO RESULT
      FROM doc_movement dm
          ,document     d
     WHERE dm.document_id = d.document_id
       AND dm.document_id = par_document_id;
    RETURN RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  PROCEDURE create_movement
  (
    par_document_id   IN NUMBER
   ,par_departmant_id IN NUMBER
   ,par_person_id     IN NUMBER
  ) IS
  BEGIN
    INSERT INTO doc_movement
      (doc_movement_id, department_to_id, person_to_id, fact_start_date, document_id, note, num)
      SELECT sq_doc_movement.nextval
            ,par_departmant_id
            ,par_person_id
            ,SYSDATE
            ,par_document_id
            ,'�������� �������� ''' || dt.name || ''' �' || d.num
            ,1
        FROM document  d
            ,doc_templ dt
       WHERE d.document_id = par_document_id
         AND dt.doc_templ_id = d.doc_templ_id;
  END;

  PROCEDURE next_movement
  (
    par_doc_move_id   IN NUMBER
   ,par_departmant_id IN NUMBER
   ,par_person_id     IN NUMBER
   ,par_note          IN VARCHAR2
  ) IS
  BEGIN
    INSERT INTO doc_movement
      (doc_movement_id, department_to_id, person_to_id, fact_start_date, document_id, num, note)
      SELECT sq_doc_movement.nextval
            ,par_departmant_id
            ,par_person_id
            ,SYSDATE
            ,document_id
            ,num + 1
            ,par_note
        FROM doc_movement
       WHERE doc_movement_id = par_doc_move_id;
  
  END;

  ------------------ ������������� �������� ���������
  FUNCTION stop_movement(par_doc_move_id IN NUMBER) RETURN NUMBER IS
    CURSOR currec(id IN NUMBER) IS
      SELECT * FROM doc_movement WHERE doc_movement_id = id FOR UPDATE;
    rec DOC_MOVEMENT%ROWTYPE;
  BEGIN
    OPEN currec(par_doc_move_id);
    FETCH currec
      INTO rec;
    IF currec%FOUND
    THEN
    
      -- ��������� ��������� �� �������� � ��������� "�� ����������"
      IF rec.t_dm_status_id <> get_status('PROCESS')
      THEN
        RAISE DME_NotAllowedOperation;
      END IF;
      UPDATE doc_movement d
         SET d.t_dm_status_id = get_status('CANCELED')
            ,d.fact_end_date  = SYSDATE
       WHERE d.doc_movement_id = par_doc_move_id;
    END IF;
    RETURN utils.get_true;
  EXCEPTION
    WHEN DME_NotAllowedOperation THEN
      IF currec%ISOPEN
      THEN
        CLOSE currec;
      END IF;
      RETURN - 2;
    WHEN OTHERS THEN
      RETURN SQLCODE;
    
  END; -- proc

  ------------------- ��������� �������� ���������
  FUNCTION close_movement(par_doc_move_id IN NUMBER) RETURN NUMBER IS
    CURSOR currec(id IN NUMBER) IS
      SELECT * FROM doc_movement WHERE doc_movement_id = id FOR UPDATE;
    rec DOC_MOVEMENT%ROWTYPE;
  BEGIN
    OPEN currec(par_doc_move_id);
    FETCH currec
      INTO rec;
    IF currec%FOUND
    THEN
    
      -- ��������� ��������� �� �������� � ��������� "�� ����������"
      IF rec.t_dm_status_id <> get_status('PROCESS')
      THEN
        RAISE DME_NotAllowedOperation;
      END IF;
      UPDATE doc_movement d
         SET d.t_dm_status_id = get_status('CLOSED')
            ,d.fact_end_date  = SYSDATE
       WHERE d.doc_movement_id = par_doc_move_id;
    END IF;
    RETURN utils.get_true;
  EXCEPTION
    WHEN DME_NotAllowedOperation THEN
      IF currec%ISOPEN
      THEN
        CLOSE currec;
      END IF;
      RETURN - 2;
    WHEN OTHERS THEN
      RETURN SQLCODE;
    
  END; -- proc

  ------------------------ ��������� �������� ��������
  FUNCTION reject_movement
  (
    par_doc_move_id IN NUMBER
   ,par_note        IN VARCHAR2
  ) RETURN NUMBER IS
    CURSOR currec(id IN NUMBER) IS
      SELECT * FROM doc_movement WHERE doc_movement_id = id FOR UPDATE;
    rec  DOC_MOVEMENT%ROWTYPE;
    v_id NUMBER;
  BEGIN
  
    OPEN currec(par_doc_move_id);
    FETCH currec
      INTO rec;
    IF currec%FOUND
    THEN
    
      -- ��������� ��������� �� �������� � ��������� "��������"
      IF rec.t_dm_status_id <> get_status('CONFIRMATION')
      THEN
        RAISE DME_NotAllowedOperation;
      END IF;
      SAVEPOINT upd;
      UPDATE doc_movement d
         SET d.t_dm_status_id = get_status('REJECTED')
            ,d.note           = par_note
            ,d.fact_end_date  = SYSDATE
       WHERE d.doc_movement_id = rec.doc_movement_id;
      v_id := rec.dm_parent_id;
      CLOSE currec;
    
      OPEN currec(v_id);
      FETCH currec
        INTO rec;
      IF currec%FOUND
      THEN
      
        UPDATE doc_movement d
           SET d.t_dm_status_id = get_status('PROCESS')
         WHERE d.doc_movement_id = rec.doc_movement_id;
      ELSE
        RAISE DME_DataNotFound;
      END IF;
      CLOSE currec;
      --else return;
    END IF;
    RETURN utils.get_true;
  EXCEPTION
    WHEN DME_DataNotFound THEN
      BEGIN
        ROLLBACK TO upd;
        IF currec%ISOPEN
        THEN
          CLOSE currec;
        END IF;
        RETURN - 1;
      END;
    WHEN DME_NotAllowedOperation THEN
      IF currec%ISOPEN
      THEN
        CLOSE currec;
      END IF;
      RETURN - 2;
    WHEN OTHERS THEN
      ROLLBACK TO upd;
      RETURN SQLCODE;
    
  END; -- proc

  --------------------- ��������� � ������ �������� ��������
  FUNCTION accept_movement(par_doc_move_id IN NUMBER) RETURN NUMBER IS
    CURSOR currec(id IN NUMBER) IS
      SELECT * FROM doc_movement WHERE doc_movement_id = id FOR UPDATE;
    rec  DOC_MOVEMENT%ROWTYPE;
    v_id NUMBER;
  BEGIN
  
    OPEN currec(par_doc_move_id);
    FETCH currec
      INTO rec;
    IF currec%FOUND
    THEN
      IF rec.t_dm_status_id <> get_status('CONFIRMATION')
         AND rec.t_dm_status_id <> get_status('NOT_DEFINED')
      THEN
        RAISE DME_NotAllowedOperation;
      END IF;
      SAVEPOINT upd;
      UPDATE doc_movement d
         SET d.t_dm_status_id  = get_status('PROCESS')
            ,d.fact_start_date = SYSDATE
       WHERE d.doc_movement_id = rec.doc_movement_id;
      /*    ����� ���� �������� �� ��� ��������� � ��������� �������� */
      v_id := rec.document_id;
      IF get_dt_id(v_id) = get_doc_templ('���������')
      THEN
        UPDATE c_claim_header ch
           SET ch.curator_id = rec.person_to_id
              ,ch.depart_id  = rec.department_to_id
         WHERE ch.c_claim_header_id = v_id;
      END IF;
    
      /*   ����� �����           */
      v_id := rec.dm_parent_id;
      CLOSE currec;
      IF rec.t_dm_status_id = get_status('NOT_DEFINED')
         AND rec.dm_parent_id IS NULL
      THEN
        RETURN utils.get_true;
      END IF;
      OPEN currec(v_id);
      FETCH currec
        INTO rec;
      IF currec%FOUND
      THEN
        UPDATE doc_movement d
           SET d.t_dm_status_id = get_status('MOVED')
              ,d.fact_end_date  = SYSDATE
         WHERE d.doc_movement_id = rec.doc_movement_id;
      ELSE
        RAISE DME_DataNotFound;
      END IF;
      CLOSE currec;
      --else return;
    END IF;
    RETURN utils.get_true;
  EXCEPTION
    WHEN DME_DataNotFound THEN
      BEGIN
        ROLLBACK TO upd;
        IF currec%ISOPEN
        THEN
          CLOSE currec;
        END IF;
        RETURN - 1;
      END;
    WHEN DME_NotAllowedOperation THEN
      IF currec%ISOPEN
      THEN
        CLOSE currec;
      END IF;
      RETURN - 2;
    WHEN OTHERS THEN
      ROLLBACK TO upd;
      RETURN SQLCODE;
  END; -- proc

  ---------------------      ���������� �������� ������� ������������
  FUNCTION deliver
  (
    par_doc_move_id   IN NUMBER
   ,par_departmant_id IN NUMBER
   ,par_person_id     IN NUMBER
   ,par_note          IN VARCHAR2
  ) RETURN NUMBER IS
  
    CURSOR currec(id IN NUMBER) IS
      SELECT * FROM doc_movement WHERE doc_movement_id = id FOR UPDATE;
    rec  DOC_MOVEMENT%ROWTYPE;
    v_id NUMBER;
  BEGIN
  
    OPEN currec(par_doc_move_id);
    FETCH currec
      INTO rec;
    IF currec%FOUND
    THEN
    
      -- ��������� ��������� �� �������� � ��������� "�� ����������"
      IF rec.t_dm_status_id <> get_status('PROCESS')
         AND rec.t_dm_status_id <> get_status('NOT_DEFINED')
      THEN
        RAISE DME_NotAllowedOperation;
      END IF;
      SAVEPOINT upd;
      UPDATE doc_movement d
         SET d.t_dm_status_id = get_status('DELIVERED')
       WHERE d.doc_movement_id = rec.doc_movement_id;
      --v_id:=rec.dm_parent_id;   
      CLOSE currec;
    
      SELECT sq_doc_movement.nextval INTO v_id FROM dual;
      INSERT INTO doc_movement
        (doc_movement_id
        ,department_to_id
        ,person_to_id
        ,fact_start_date
        ,document_id
        ,note
        ,num
        ,t_dm_status_id
        ,dm_parent_id)
      VALUES
        (v_id
        ,par_departmant_id
        ,par_person_id
        ,SYSDATE
        ,rec.document_id
        ,par_note
        ,rec.num
        ,get_status('CONFIRMATION')
        ,rec.doc_movement_id);
    
    ELSE
      RAISE DME_DataNotFound;
    END IF;
    RETURN utils.get_true;
  EXCEPTION
    WHEN DME_DataNotFound THEN
      BEGIN
        ROLLBACK TO upd;
        IF currec%ISOPEN
        THEN
          CLOSE currec;
        END IF;
        RETURN - 1;
      END;
    WHEN DME_NotAllowedOperation THEN
      IF currec%ISOPEN
      THEN
        CLOSE currec;
      END IF;
      RETURN - 2;
    WHEN OTHERS THEN
      ROLLBACK TO upd;
      RETURN SQLCODE;
  END; -- proc

  ----------------- ������ ��������� ��������� 
  FUNCTION cancel_deliver(par_doc_move_id IN NUMBER) RETURN NUMBER IS
    CURSOR currec(id IN NUMBER) IS
      SELECT * FROM doc_movement WHERE doc_movement_id = id FOR UPDATE;
    CURSOR currec1(id IN NUMBER) IS
      SELECT *
        FROM doc_movement
       WHERE dm_parent_id = id
         AND t_dm_status_id = get_status('CONFIRMATION')
         FOR UPDATE;
    rec DOC_MOVEMENT%ROWTYPE;
    --v_id number;
  BEGIN
  
    OPEN currec(par_doc_move_id);
    FETCH currec
      INTO rec;
    IF currec%FOUND
    THEN
    
      -- ��������� ��������� �� �������� � ��������� "�� �������������"
      IF rec.t_dm_status_id <> get_status('DELIVERED')
      THEN
        RAISE DME_NotAllowedOperation;
      END IF;
      SAVEPOINT upd;
      UPDATE doc_movement d
         SET d.t_dm_status_id = get_status('PROCESS')
       WHERE d.doc_movement_id = rec.doc_movement_id;
      --v_id:=rec.dm_parent_id;
      CLOSE currec;
    
      OPEN currec1(par_doc_move_id);
      FETCH currec1
        INTO rec;
      IF currec1%FOUND
      THEN
        DELETE FROM doc_movement d WHERE d.doc_movement_id = rec.doc_movement_id;
      END IF;
      CLOSE currec1;
    ELSE
      CLOSE currec;
    END IF;
    RETURN utils.get_true;
  EXCEPTION
    WHEN DME_NotAllowedOperation THEN
      IF currec%ISOPEN
      THEN
        CLOSE currec;
      END IF;
      RETURN - 2;
    WHEN OTHERS THEN
      ROLLBACK TO upd;
      RETURN SQLCODE;
  END; --proc
END pkg_doc_move;
/

CREATE OR REPLACE FUNCTION is_agent_ds_date_error (p_ach_id IN VARCHAR2) RETURN NUMBER IS
CURSOR c_versions IS
SELECT      doc_c.num
            ,ac.date_begin
            ,LEAD(ac.date_begin, 1) OVER (ORDER BY ac.date_begin) next_st_date
FROM        ag_contract             ac
            ,ag_contract_header     ach
            --,document               doc_h
            ,document               doc_c
WHERE       ach.ag_contract_header_id  =    ac.contract_id
AND         ac.ag_contract_id          =    doc_c.document_id
--AND         ach.ag_contract_header_id  =    doc_h.document_id
--AND         doc_h.num                  =    p_ag_cont_num--'003784'
ORDER BY doc_c.num ASC;
v_ver1 c_versions%ROWTYPE;
v_ver2 c_versions%ROWTYPE;
prizn NUMBER;
BEGIN
    prizn := 0;
    OPEN  c_versions;
    FETCH c_versions INTO v_ver1;
    FETCH c_versions INTO v_ver2;
    WHILE c_versions%FOUND LOOP
        IF (v_ver2.date_begin < v_ver1.date_begin) THEN
            prizn := 1;
            --dbms_output.put_line(to_char(prizn));
            EXIT;
        ELSE
            v_ver1 := v_ver2;
            FETCH c_versions INTO v_ver2;            
        END IF;
    END LOOP;
    CLOSE c_versions;
    RETURN prizn;
END is_agent_ds_date_error;
/


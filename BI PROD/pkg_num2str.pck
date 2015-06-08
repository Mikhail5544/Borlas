CREATE OR REPLACE PACKAGE pkg_num2str AS
  ----========================================================================----
  -- ����� ��������. 
  -- ������� ��������: par_num: 123456789012.12 - �� ����� 15 ������ � �����, 
  -- ������ � ������������ � ������� ������. ������� ����� ����� 
  -- �������������.
  -- par_fund_brief - ������: RUR, USD ��� EUR
  FUNCTION Num_To_Str
  (
    par_num        NUMBER
   ,par_fund_brief VARCHAR2
  ) RETURN VARCHAR2;
  ----========================================================================----
END PKG_NUM2STR;
/
CREATE OR REPLACE PACKAGE BODY pkg_num2str AS
  ----========================================================================----
  -- ����� ��������. 
  -- ������� ��������: par_num: 123456789012.12 - �� ����� 15 ������ � �����, 
  -- ������ � ������������ � ������� ������. ������� ����� ����� 
  -- �������������.
  -- par_fund_brief - ������: RUR, USD ��� EUR
  FUNCTION Num_To_Str
  (
    par_num        NUMBER
   ,par_fund_brief VARCHAR2
  ) RETURN VARCHAR2 IS
    v_stmon VARCHAR2(255) := ''; -- ��������� (������������ ������)
    v_st    VARCHAR2(15); -- ��������������� ����������
    v_char3 VARCHAR2(3); -- ��� �����
    v_tr1   VARCHAR2(1); -- �����
    v_tr2   VARCHAR2(1); -- �������
    v_tr3   VARCHAR2(1); -- �������
    v_kop1  VARCHAR2(1); -- ������� ������
    v_kop2  VARCHAR2(1); -- ������� ������
  BEGIN
    -- {����������� �� ����� � ������}
    v_st := SUBSTR((TO_CHAR(ABS(par_num), '999999999990D00')), 2, 15);
    FOR i IN 1 .. 5
    LOOP
      -- �������� ��� �����
      v_char3 := SUBSTR(v_st, 1, 3);
      v_st    := SUBSTR(v_st, 4, (LENGTH(v_st) - 3));
      -- ������ ����� �� ���
      v_tr1 := SUBSTR(v_char3, 1, 1);
      -- ������ ����� �� ���
      v_tr2 := SUBSTR(v_char3, 2, 1);
      -- ������ ����� �� ���
      v_tr3 := SUBSTR(v_char3, 3, 1);
      -- ��������� ����� ����� �����
      IF i <> 5
      THEN
        -- ��������� ������ �����
        IF v_tr1 = '1'
        THEN
          v_stmon := v_stmon || '��� ';
        ELSIF v_tr1 = '2'
        THEN
          v_stmon := v_stmon || '������ ';
        ELSIF v_tr1 = '3'
        THEN
          v_stmon := v_stmon || '������ ';
        ELSIF v_tr1 = '4'
        THEN
          v_stmon := v_stmon || '��������� ';
        ELSIF v_tr1 = '5'
        THEN
          v_stmon := v_stmon || '������� ';
        ELSIF v_tr1 = '6'
        THEN
          v_stmon := v_stmon || '�������� ';
        ELSIF v_tr1 = '7'
        THEN
          v_stmon := v_stmon || '������� ';
        ELSIF v_tr1 = '8'
        THEN
          v_stmon := v_stmon || '��������� ';
        ELSIF v_tr1 = '9'
        THEN
          v_stmon := v_stmon || '��������� ';
        END IF;
        -- ��������� 2 �����
        IF v_tr2 = '1'
        THEN
          IF v_tr3 = '0'
          THEN
            v_stmon := v_stmon || '������ ';
          ELSIF v_tr3 = '1'
          THEN
            v_stmon := v_stmon || '����������� ';
          ELSIF v_tr3 = '2'
          THEN
            v_stmon := v_stmon || '���������� ';
          ELSIF v_tr3 = '3'
          THEN
            v_stmon := v_stmon || '�p�������� ';
          ELSIF v_tr3 = '4'
          THEN
            v_stmon := v_stmon || '����p������� ';
          ELSIF v_tr3 = '5'
          THEN
            v_stmon := v_stmon || '���������� ';
          ELSIF v_tr3 = '6'
          THEN
            v_stmon := v_stmon || '����������� ';
          ELSIF v_tr3 = '7'
          THEN
            v_stmon := v_stmon || '���������� ';
          ELSIF v_tr3 = '8'
          THEN
            v_stmon := v_stmon || '������������ ';
          ELSIF v_tr3 = '9'
          THEN
            v_stmon := v_stmon || '������������ ';
          END IF;
        ELSIF v_tr2 = '2'
        THEN
          v_stmon := v_stmon || '�������� ';
        ELSIF v_tr2 = '3'
        THEN
          v_stmon := v_stmon || '�p������ ';
        ELSIF v_tr2 = '4'
        THEN
          v_stmon := v_stmon || '��p�� ';
        ELSIF v_tr2 = '5'
        THEN
          v_stmon := v_stmon || '��������� ';
        ELSIF v_tr2 = '6'
        THEN
          v_stmon := v_stmon || '���������� ';
        ELSIF v_tr2 = '7'
        THEN
          v_stmon := v_stmon || '��������� ';
        ELSIF v_tr2 = '8'
        THEN
          v_stmon := v_stmon || '����������� ';
        ELSIF v_tr2 = '9'
        THEN
          v_stmon := v_stmon || '��������� ';
        END IF;
        -- ��������� 3 �����
        IF v_tr2 != '1'
        THEN
          IF v_tr3 = '1'
             AND i != 3
          THEN
            v_stmon := v_stmon || '���� ';
          ELSIF v_tr3 = '1'
                AND i = 3
          THEN
            v_stmon := v_stmon || '���� ';
          ELSIF v_tr3 = '2'
                AND i != 3
          THEN
            v_stmon := v_stmon || '��� ';
          ELSIF v_tr3 = '2'
                AND i = 3
          THEN
            v_stmon := v_stmon || '��� ';
          ELSIF v_tr3 = '3'
          THEN
            v_stmon := v_stmon || '�p� ';
          ELSIF v_tr3 = '4'
          THEN
            v_stmon := v_stmon || '����p� ';
          ELSIF v_tr3 = '5'
          THEN
            v_stmon := v_stmon || '���� ';
          ELSIF v_tr3 = '6'
          THEN
            v_stmon := v_stmon || '����� ';
          ELSIF v_tr3 = '7'
          THEN
            v_stmon := v_stmon || '���� ';
          ELSIF v_tr3 = '8'
          THEN
            v_stmon := v_stmon || '������ ';
          ELSIF v_tr3 = '9'
          THEN
            v_stmon := v_stmon || '������ ';
          END IF;
        END IF;
        -- ��������� ����������
        IF i = 1
        THEN
          IF (v_tr1 = ' ')
             AND (v_tr2 = ' ')
             AND (v_tr3 = ' ')
          THEN
            NULL;
          ELSIF (v_tr1 = '0')
                AND (v_tr2 = '0')
                AND (v_tr3 = '0')
          THEN
            NULL;
          ELSIF (v_tr3 = '1')
                AND (v_tr2 != '1')
          THEN
            v_stmon := v_stmon || '������p� ';
          ELSIF (v_tr3 = '2' OR v_tr3 = '3' OR v_tr3 = '4')
                AND (v_tr2 != '1')
          THEN
            v_stmon := v_stmon || '������p�� ';
          ELSE
            v_stmon := v_stmon || '������p��� ';
          END IF;
        END IF;
        -- ��������� ���������
        IF i = 2
        THEN
          IF (v_tr1 = ' ')
             AND (v_tr2 = ' ')
             AND (v_tr3 = ' ')
          THEN
            NULL;
          ELSIF (v_tr1 = '0')
                AND (v_tr2 = '0')
                AND (v_tr3 = '0')
          THEN
            NULL;
          ELSIF (v_tr3 = '1')
                AND (v_tr2 != '1')
          THEN
            v_stmon := v_stmon || '������� ';
          ELSIF (v_tr3 = '2' OR v_tr3 = '3' OR v_tr3 = '4')
                AND (v_tr2 != '1')
          THEN
            v_stmon := v_stmon || '�������� ';
          ELSE
            v_stmon := v_stmon || '��������� ';
          END IF;
        END IF;
        -- ��������� �����
        IF i = 3
        THEN
          IF (v_tr1 = ' ')
             AND (v_tr2 = ' ')
             AND (v_tr3 = ' ')
          THEN
            NULL;
          ELSIF (v_tr1 = '0')
                AND (v_tr2 = '0')
                AND (v_tr3 = '0')
          THEN
            NULL;
          ELSIF (v_tr3 = '1')
                AND (v_tr2 <> '1')
          THEN
            v_stmon := v_stmon || '������ ';
          ELSIF (v_tr3 = '2' OR v_tr3 = '3' OR v_tr3 = '4')
                AND (v_tr2 <> '1')
          THEN
            v_stmon := v_stmon || '������ ';
          ELSE
            v_stmon := v_stmon || '����� ';
          END IF;
        END IF;
        -- ��������� �����
        IF i = 4
        THEN
          IF (v_tr1 = ' ')
             AND (v_tr2 = ' ')
             AND (v_tr3 = ' ')
          THEN
            NULL;
          ELSIF (v_tr3 = '1')
                AND (v_tr2 != '1')
          THEN
            IF par_fund_brief = 'RUR'
            THEN
              v_stmon := v_stmon || 'p���� ';
            ELSIF par_fund_brief = 'USD'
            THEN
              v_stmon := v_stmon || '������ ';
            ELSIF par_fund_brief = 'EUR'
            THEN
              v_stmon := v_stmon || '���� ';
            END IF;
          ELSIF (v_tr3 = '2' OR v_tr3 = '3' OR v_tr3 = '4')
                AND (v_tr2 != '1')
          THEN
            IF par_fund_brief = 'RUR'
            THEN
              v_stmon := v_stmon || 'p���� ';
            ELSIF par_fund_brief = 'USD'
            THEN
              v_stmon := v_stmon || '������� ';
            ELSIF par_fund_brief = 'EUR'
            THEN
              v_stmon := v_stmon || '���� ';
            END IF;
          ELSIF (v_tr1 = ' ')
                AND (v_tr2 = ' ')
                AND (v_tr3 = '0')
          THEN
            IF par_fund_brief = 'RUR'
            THEN
              v_stmon := v_stmon || '���� p����� ';
            ELSIF par_fund_brief = 'USD'
            THEN
              v_stmon := v_stmon || '���� �������� ';
            ELSIF par_fund_brief = 'EUR'
            THEN
              v_stmon := v_stmon || '���� ���� ';
            END IF;
          ELSE
            IF par_fund_brief = 'RUR'
            THEN
              v_stmon := v_stmon || 'p����� ';
            ELSIF par_fund_brief = 'USD'
            THEN
              v_stmon := v_stmon || '�������� ';
            ELSIF par_fund_brief = 'EUR'
            THEN
              v_stmon := v_stmon || '���� ';
            END IF;
          END IF;
        END IF;
      ELSIF i = 5
      THEN
        -- ��������� �������� ������
        v_kop1 := SUBSTR(v_char3, 2, 1);
        -- ��������� ������ ������
        v_kop2 := SUBSTR(v_char3, 3, 1);
        -- {���������� ������ � �������������� ������}
        v_stmon := v_stmon || v_kop1 || v_kop2 || ' ';
        IF (v_kop2 = '1')
           AND (v_kop1 != '1')
        THEN
          IF par_fund_brief = 'RUR'
          THEN
            v_stmon := v_stmon || '�������';
          ELSIF par_fund_brief = 'USD'
          THEN
            v_stmon := v_stmon || '����';
          ELSIF par_fund_brief = 'EUR'
          THEN
            v_stmon := v_stmon || '��������';
          END IF;
        ELSIF (v_kop2 = '2' OR v_kop2 = '3' OR v_kop2 = '4')
              AND (v_kop1 != '1')
        THEN
          IF par_fund_brief = 'RUR'
          THEN
            v_stmon := v_stmon || '�������';
          ELSIF par_fund_brief = 'USD'
          THEN
            v_stmon := v_stmon || '�����';
          ELSIF par_fund_brief = 'EUR'
          THEN
            v_stmon := v_stmon || '���������';
          END IF;
        ELSE
          IF par_fund_brief = 'RUR'
          THEN
            v_stmon := v_stmon || '������';
          ELSIF par_fund_brief = 'USD'
          THEN
            v_stmon := v_stmon || '������';
          ELSIF par_fund_brief = 'EUR'
          THEN
            v_stmon := v_stmon || '����������';
          END IF;
        END IF;
      END IF;
    END LOOP;
    -- �������������� ������� ������� ������ � ��������� �����
    v_stmon := UPPER(SUBSTR(v_stmon, 1, 1)) || SUBSTR(v_stmon, 2, (LENGTH(v_stmon) - 1));
    RETURN(v_stmon);
  END Num_To_Str;
  ----========================================================================----
  /*
  FUNCTION get_sum_str_2 (source IN NUMBER)
  RETURN varchar2 is result VARCHAR2(300);
  BEGIN
  -- k - �������
    if source < 1
       then
          result := '���� '||
             ltrim(
                   to_char(
                           source,'9,9,,9,,,,,,9,9,,9,,,,,9,9,,9,,,,9,9,,9,,,.99'
                          )
                  ) || 'k';
       else
          result := ltrim(
                          to_char
                          (
                           source,'9,9,,9,,,,,,9,9,,9,,,,,9,9,,9,,,,9,9,,9,,,.99'
                          )
                         ) || 'k';
    end if;
  
  -- t - ������; m - �������; M - ���������;
    result := replace( result, ',,,,,,', 'eM');
    result := replace( result, ',,,,,', 'em');
    result := replace( result, ',,,,', 'et');
  -- e - �������; d - �������; c - �����;
    result := replace( result, ',,,', 'e');
    result := replace( result, ',,', 'd');
    result := replace( result, ',', 'c');
  -- �������� ���������� �����
    result := replace( result, '0c0d0et', '');
    result := replace( result, '0c0d0em', '');
    result := replace( result, '0c0d0eM', '');
  
  -- ��������� �����
    result := replace( result, '0c', '');
    result := replace( result, '1c', '��� ');
    result := replace( result, '2c', '������ ');
    result := replace( result, '3c', '������ ');
    result := replace( result, '4c', '��������� ');
    result := replace( result, '5c', '������� ');
    result := replace( result, '6c', '�������� ');
    result := replace( result, '7c', '������� ');
    result := replace( result, '8c', '��������� ');
    result := replace( result, '9c', '��������� ');
  
  -- ��������� ��������
    result := replace( result, '1d0e', '������ ');
    result := replace( result, '1d1e', '����������� ');
    result := replace( result, '1d2e', '���������� ');
    result := replace( result, '1d3e', '���������� ');
    result := replace( result, '1d4e', '������������ ');
    result := replace( result, '1d5e', '���������� ');
    result := replace( result, '1d6e', '����������� ');
    result := replace( result, '1d7e', '����������� ');
    result := replace( result, '1d8e', '������������ ');
    result := replace( result, '1d9e', '������������ ');
    result := replace( result, '0d', '');
    result := replace( result, '2d', '�������� ');
    result := replace( result, '3d', '�������� ');
    result := replace( result, '4d', '����� ');
    result := replace( result, '5d', '��������� ');
    result := replace( result, '6d', '���������� ');
    result := replace( result, '7d', '��������� ');
    result := replace( result, '8d', '����������� ');
    result := replace( result, '9d', '��������� ');
  
  -- ��������� ������
    result := replace( result, '0e', '');
    result := replace( result, '5e', '���� ');
    result := replace( result, '6e', '����� ');
    result := replace( result, '7e', '���� ');
    result := replace( result, '8e', '������ ');
    result := replace( result, '9e', '������ ');
  --
    result := replace( result, '1e.', '���� ����� ');
    result := replace( result, '2e.', '��� ����� ');
    result := replace( result, '3e.', '��� ����� ');
    result := replace( result, '4e.', '������ ����� ');
    result := replace( result, '1et', '���� ������ ');
    result := replace( result, '2et', '��� ������ ');
    result := replace( result, '3et', '��� ������ ');
    result := replace( result, '4et', '������ ������ ');
    result := replace( result, '1em', '���� ������� ');
    result := replace( result, '2em', '��� �������� ');
    result := replace( result, '3em', '��� �������� ');
    result := replace( result, '4em', '������ �������� ');
    result := replace( result, '1eM', '���� ������� ');
    result := replace( result, '2eM', '��� �������� ');
    result := replace( result, '3eM', '��� �������� ');
    result := replace( result, '4eM', '������ �������� ');
  
  -- ��������� ������
    result := replace( result, '11k', '11 ������');
    result := replace( result, '12k', '12 ������');
    result := replace( result, '13k', '13 ������');
    result := replace( result, '14k', '14 ������');
    result := replace( result, '1k', '1 �������');
    result := replace( result, '2k', '2 �������');
    result := replace( result, '3k', '3 �������');
    result := replace( result, '4k', '4 �������');
  
  -- ��������� �������� �����
    result := replace( result, '.', '������ ');
    result := replace( result, 't', '����� ');
    result := replace( result, 'm', '��������� ');
    result := replace( result, 'M', '��������� ');
    result := replace( result, 'k', ' ������');
  --
    RETURN(result);
  END get_sum_str_2; 
  */
  ----========================================================================----

  /* �������� ������� �������� ���� � ������ � ����������� ������ */
  FUNCTION daterusr(d DATE) RETURN VARCHAR2 IS
    /* entry - date
    exit - date in russian text roditelnij padej */
    ds    VARCHAR2(100);
    DAY   CHAR(2);
    MONTH CHAR(2);
    YEAR  CHAR(4);
  BEGIN
    IF d < TO_DATE('01-01-1990', 'DD-MM-YYYY')
    THEN
      RETURN '�������� �������� ���: 01.01.1990 - 31.12.2020. ������: ' || TO_CHAR(d, 'YYYY');
    ELSIF d > TO_DATE('31-12-2020', 'DD-MM-YYYY')
    THEN
      RETURN '�������� �������� ���: 01.01.1990 - 31.12.2020. ������: ' || TO_CHAR(d, 'YYYY');
    ELSE
      DAY   := TO_CHAR(d, 'DD');
      MONTH := TO_CHAR(d, 'MM');
      YEAR  := TO_CHAR(d, 'YYYY');
    
      IF DAY = '01'
      THEN
        ds := '������� ';
      ELSIF DAY = '02'
      THEN
        ds := '������� ';
      ELSIF DAY = '03'
      THEN
        ds := '�������� ';
      ELSIF DAY = '04'
      THEN
        ds := '���������� ';
      ELSIF DAY = '05'
      THEN
        ds := '������ ';
      ELSIF DAY = '06'
      THEN
        ds := '������� ';
      ELSIF DAY = '07'
      THEN
        ds := '�������� ';
      ELSIF DAY = '08'
      THEN
        ds := '�������� ';
      ELSIF DAY = '09'
      THEN
        ds := '�������� ';
      ELSIF DAY = '10'
      THEN
        ds := '�������� ';
      ELSIF DAY = '11'
      THEN
        ds := '������������� ';
      ELSIF DAY = '12'
      THEN
        ds := '������������ ';
      ELSIF DAY = '13'
      THEN
        ds := '������������ ';
      ELSIF DAY = '14'
      THEN
        ds := '�������������� ';
      ELSIF DAY = '15'
      THEN
        ds := '������������ ';
      ELSIF DAY = '16'
      THEN
        ds := '������������� ';
      ELSIF DAY = '17'
      THEN
        ds := '������������ ';
      ELSIF DAY = '18'
      THEN
        ds := '�������������� ';
      ELSIF DAY = '19'
      THEN
        ds := '�������������� ';
      ELSIF DAY = '20'
      THEN
        ds := '���������� ';
      ELSIF DAY = '21'
      THEN
        ds := '�������� ������� ';
      ELSIF DAY = '22'
      THEN
        ds := '�������� ������� ';
      ELSIF DAY = '23'
      THEN
        ds := '�������� ������� ';
      ELSIF DAY = '24'
      THEN
        ds := '�������� ���������� ';
      ELSIF DAY = '25'
      THEN
        ds := '�������� ������ ';
      ELSIF DAY = '26'
      THEN
        ds := '�������� ������� ';
      ELSIF DAY = '27'
      THEN
        ds := '�������� �������� ';
      ELSIF DAY = '28'
      THEN
        ds := '�������� �������� ';
      ELSIF DAY = '29'
      THEN
        ds := '�������� �������� ';
      ELSIF DAY = '30'
      THEN
        ds := '���������� ';
      ELSIF DAY = '31'
      THEN
        ds := '�������� ������� ';
      END IF;
    
      IF MONTH = '01'
      THEN
        ds := ds || '������ ';
      ELSIF MONTH = '02'
      THEN
        ds := ds || '������� ';
      ELSIF MONTH = '03'
      THEN
        ds := ds || '����� ';
      ELSIF MONTH = '04'
      THEN
        ds := ds || '������ ';
      ELSIF MONTH = '05'
      THEN
        ds := ds || '��� ';
      ELSIF MONTH = '06'
      THEN
        ds := ds || '���� ';
      ELSIF MONTH = '07'
      THEN
        ds := ds || '���� ';
      ELSIF MONTH = '08'
      THEN
        ds := ds || '������� ';
      ELSIF MONTH = '09'
      THEN
        ds := ds || '�������� ';
      ELSIF MONTH = '10'
      THEN
        ds := ds || '������� ';
      ELSIF MONTH = '11'
      THEN
        ds := ds || '������ ';
      ELSIF MONTH = '12'
      THEN
        ds := ds || '������� ';
      END IF;
    
      IF YEAR = '1990'
      THEN
        ds := ds || '���� ������ ��������� �����������';
      ELSIF YEAR = '1991'
      THEN
        ds := ds || '���� ������ ��������� ��������� �������';
      ELSIF YEAR = '1992'
      THEN
        ds := ds || '���� ������ ��������� ��������� �������';
      ELSIF YEAR = '1993'
      THEN
        ds := ds || '���� ������ ��������� ��������� ��������';
      ELSIF YEAR = '1994'
      THEN
        ds := ds || '���� ������ ��������� ��������� ����������';
      ELSIF YEAR = '1995'
      THEN
        ds := ds || '���� ������ ��������� ��������� ������';
      ELSIF YEAR = '1996'
      THEN
        ds := ds || '���� ������ ��������� ��������� �������';
      ELSIF YEAR = '1997'
      THEN
        ds := ds || '���� ������ ��������� ��������� ��������';
      ELSIF YEAR = '1998'
      THEN
        ds := ds || '���� ������ ��������� ��������� ��������';
      ELSIF YEAR = '1999'
      THEN
        ds := ds || '���� ������ ��������� ��������� ��������';
      ELSIF YEAR = '2000'
      THEN
        ds := ds || '�������������';
      ELSIF YEAR = '2001'
      THEN
        ds := ds || '��� ������ �������';
      ELSIF YEAR = '2002'
      THEN
        ds := ds || '��� ������ �������';
      ELSIF YEAR = '2003'
      THEN
        ds := ds || '��� ������ ��������';
      ELSIF YEAR = '2004'
      THEN
        ds := ds || '��� ������ ����������';
      ELSIF YEAR = '2005'
      THEN
        ds := ds || '��� ������ ������';
      ELSIF YEAR = '2006'
      THEN
        ds := ds || '��� ������ �������';
      ELSIF YEAR = '2007'
      THEN
        ds := ds || '��� ������ ��������';
      ELSIF YEAR = '2008'
      THEN
        ds := ds || '��� ������ ��������';
      ELSIF YEAR = '2009'
      THEN
        ds := ds || '��� ������ ��������';
      ELSIF YEAR = '2010'
      THEN
        ds := ds || '��� ������ ��������';
      ELSIF YEAR = '2011'
      THEN
        ds := ds || '��� ������ �������������';
      ELSIF YEAR = '2012'
      THEN
        ds := ds || '��� ������ ������������';
      ELSIF YEAR = '2013'
      THEN
        ds := ds || '��� ������ ������������';
      ELSIF YEAR = '2014'
      THEN
        ds := ds || '��� ������ ��������������';
      ELSIF YEAR = '2015'
      THEN
        ds := ds || '��� ������ ������������';
      ELSIF YEAR = '2016'
      THEN
        ds := ds || '��� ������ �������������';
      ELSIF YEAR = '2017'
      THEN
        ds := ds || '��� ������ ������������';
      ELSIF YEAR = '2018'
      THEN
        ds := ds || '��� ������ ��������������';
      ELSIF YEAR = '2019'
      THEN
        ds := ds || '��� ������ ��������������';
      ELSIF YEAR = '2020'
      THEN
        ds := ds || '��� ������ ����������';
      END IF;
      ds := ds || ' ����';
      RETURN ds;
    END IF;
  END daterusr;
  ----========================================================================----
END PKG_NUM2STR;
/

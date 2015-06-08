CREATE OR REPLACE PACKAGE PKG_UTILS IS

  -- Author  : RKUDRYAVCEV
  -- Created : 06.08.2007 12:46:50
  -- Purpose : ��������������� �����

  ------------------------------------------------------------------------  
  --
  -- ������� ������ ����� ��������.
  -- � ������� 2-����
  --
  --------------------------------------------------------------------------
  FUNCTION Get_addr_2NDFL(par_address_id ins.cn_address.id%TYPE) RETURN VARCHAR2;

END PKG_UTILS;
/
CREATE OR REPLACE PACKAGE BODY PKG_UTILS IS

  ------------------------------------------------------------------------  
  --
  -- ������� ������ ����� ��������.
  -- � ������� 2-����
  --
  --------------------------------------------------------------------------
  FUNCTION Get_addr_2NDFL(par_address_id ins.cn_address.id%TYPE) RETURN VARCHAR2 IS
    var_address VARCHAR2(2000);
  BEGIN
  
    --,404126,������������� ���,,�������� �,,������������ ��,41,,165
    -- ���� ������ � ��, �� ������ ���������:
    -- ,<������>,
    -- �������� ������������ ����, �������, ��������, ���������� ������� � �������
    -- ������� �� ��������������� ������������, �.�. ������������ ��� ���� - �� ����� ������
    SELECT decode(c.country_code
                 ,643
                 , -- ��,
                  NULL
                 ,c.country_code) || ',' || -- ������
           ca.zip || ',' || -- ������
           decode(p.province_name, NULL, NULL, p.province_name || ' ' || pt.description_short) || ',' || -- �������
           decode(r.region_name, NULL, NULL, r.region_name || ' ' || rt.description_short) || ',' || -- �����
           decode(tc.city_name, NULL, NULL, tc.city_name || ' ' || tct.description_short) || ',' || -- �����
           decode(d.district_name, NULL, NULL, d.district_name || ' ' || dt.description_short) || ',' || -- ��� �����
           decode(s.street_name, NULL, NULL, s.street_name || ' ' || st.description_short) || ',' || -- �����
           ca.house_nr || ',' || -- ����� ����
           ca.block_number || ',' || -- ��������
           ca.appartment_nr -- ����� ��������
      INTO var_address
      FROM ins.t_country       c
          ,ins.cn_address      ca
          ,ins.t_province      p
          ,ins.t_province_type pt
          ,ins.t_region        r
          ,ins.t_region_type   rt
          ,ins.t_city          tc
          ,ins.t_city_type     tct
          ,ins.t_district      d
          ,ins.t_district_type dt
          ,ins.t_street        s
          ,ins.t_street_type   st
     WHERE ca.country_id = c.id
       AND ca.province_id = p.province_id(+)
       AND p.province_type_id = pt.province_type_id(+)
       AND ca.region_id = r.region_id(+)
       AND r.region_type_id = rt.region_type_id(+)
       AND ca.city_id = tc.city_id(+)
       AND tc.city_type_id = tct.city_type_id(+)
       AND ca.district_id = d.district_id(+)
       AND d.district_type_id = dt.district_type_id(+)
       AND ca.street_id = s.street_id(+)
       AND s.street_type_id = st.street_type_id(+)
       AND ca.id = par_address_id;
  
    RETURN REPLACE(var_address, ',,,,,,,,,');
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END Get_addr_2NDFL;
  ----
END PKG_UTILS;
/

CREATE OR REPLACE PACKAGE pkg_rep_invest_declaration IS

  -- Author  : ������ �.
  -- Created : 29.04.2015 
  -- Purpose : ������ �������������� ����������

  /**
  * �������: �������� � �������������� ������ ������; �����: 148, 681
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_1
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * �������: �������� ������� � ��.�.������ (������)+ ��� ��������; �����: 149
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_2
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * �������: �������� ������� � ��. �. ���.(����� � �����); �����: 517
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_3
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * �������: 
      �������� ������� (����� - ��� "��������-������������� ����"); �����: 626
      �������� ������� (����� � �����); �����: 505
      �������� ������� (����� � ������ ������ ����); �����: 607    
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_4
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * �������: ����� � �������; �����: 508, 519, 521, ���� ������� < 01.10.2013
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_5_before
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * �������: ����� � �������; �����: 508, 519, 521, ���� ������� >= 01.10.2013
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_5_after
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * �������: �������� ������� � ��. �. ���. (����� � ���24); �����: 682, ���� ������� < 01.12.2014
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_6_before
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * �������: �������� ������� � ��. �. ���. (����� � ���24); �����: 682, ���� ������� >= 01.12.2014
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_6_after
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * �������: �������� ������� � ��. �. ���.(����� � ���); �����: 675, ���� ������� < 01.04.2014
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_7_before
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * �������: �������� ������� � ��. �. ���.(����� � ���); �����: 675, ���� ������� >= 01.04.2014
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_7_after
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * �������: �������� ����; �����:618, 686
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_8
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * �������: ��������_new (5 ���, �������� ��� ���); ����� 679: 
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_9
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * �������: ��������� ������ (�������������� ��������) ��������; ����� 615: 
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_10
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * �������: ��������� ������ (���������� ��������) ��������; ����� 614: 
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_11
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

END pkg_rep_invest_declaration;
/
CREATE OR REPLACE PACKAGE BODY pkg_rep_invest_declaration IS

  gc_filename VARCHAR2(100) := 'invest_declaration.pdf';

  /**
  * �������� BLOB �������
  * @author ������ �. 30.04.2015
  */
  FUNCTION get_template_blob RETURN BLOB IS
    v_template_blob BLOB;
    v_rep_report_id rep_report.rep_report_id%TYPE;
  BEGIN
    v_rep_report_id := to_number(repcore.get_context('REP_REPORT_ID'));
  
    SELECT t.templ
      INTO v_template_blob
      FROM rep_report r
          ,rep_templ  t
     WHERE r.rep_report_id = v_rep_report_id
       AND r.rep_templ_id = t.rep_templ_id;
    RETURN v_template_blob;
  EXCEPTION
    WHEN no_data_found
         OR too_many_rows THEN
      RETURN NULL;
  END get_template_blob;

  /**
  * �������: �������� � �������������� ������ ������; �����: 148, 681
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_1
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_1;

  /**
  * �������: �������� ������� � ��.�.������ (������)+ ��� ��������; �����: 149
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_2
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_2;

  /**
  * �������: �������� ������� � ��. �. ���.(����� � �����); �����: 517
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_3
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_3;

  /**
  * �������: 
      �������� ������� (����� - ��� "��������-������������� ����"); �����: 626
      �������� ������� (����� � �����); �����: 505
      �������� ������� (����� � ������ ������ ����); �����: 607    
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_4
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_4;

  /**
  * �������: ����� � �������; �����: 508, 519, 521, ���� ������� < 01.10.2013
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_5_before
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_5_before;

  /**
  * �������: ����� � �������; �����: 508, 519, 521, ���� ������� >= 01.10.2013
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_5_after
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_5_after;

  /**
  * �������: �������� ������� � ��. �. ���. (����� � ���24); �����: 682, ���� ������� < 01.12.2014
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_6_before
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_6_before;

  /**
  * �������: �������� ������� � ��. �. ���. (����� � ���24); �����: 682, ���� ������� >= 01.12.2014
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_6_after
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_6_after;

  /**
  * �������: �������� ������� � ��. �. ���.(����� � ���); �����: 675, ���� ������� < 01.04.2014
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_7_before
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_7_before;

  /**
  * �������: �������� ������� � ��. �. ���.(����� � ���); �����: 675, ���� ������� >= 01.04.2014
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_7_after
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_7_after;

  /**
  * �������: �������� ����; �����:618, 686
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_8
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_8;

  /**
  * �������: ��������_new (5 ���, �������� ��� ���); ����� 679: 
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_9
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_9;

  /**
  * �������: ��������� ������ (�������������� ��������) ��������; ����� 615: 
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_10
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_10;

  /**
  * �������: ��������� ������ (���������� ��������) ��������; ����� 614: 
  * @author ������ �. 30.04.2015
  */
  PROCEDURE invest_declaration_11
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_11;

END pkg_rep_invest_declaration;
/

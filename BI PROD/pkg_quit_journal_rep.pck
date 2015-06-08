CREATE OR REPLACE PACKAGE pkg_quit_journal_rep IS

  --���������� ���� ��������� ������ ��������������
  FUNCTION get_recover_date(par_policy_id NUMBER) RETURN DATE;

  --���������� id ��������� ������ ��������������
  FUNCTION get_recover_policy_id(par_policy_id NUMBER) RETURN NUMBER;

  --��������� ����� ��. ������ ����������� 
  FUNCTION create_quit_journal
  (
    par_date_begin     DATE
   ,par_date_end       DATE
   ,par_regulated_loss VARCHAR2 -- ��������������� ������
   ,par_claimed_loss   VARCHAR2 -- ���������� ������
   ,par_renew_quit     VARCHAR2 -- �������������� � ����������� �� ��������� ��������� �������
   ,par_setoff_fin     VARCHAR2 -- �����/���������� ��������
  ) RETURN NUMBER;

END pkg_quit_journal_rep; 
/
CREATE OR REPLACE PACKAGE BODY pkg_quit_journal_rep IS

  --���������� ���� ��������� ������ ��������������
  FUNCTION get_recover_date(par_policy_id NUMBER) RETURN DATE IS
    v_act_date  DATE;
    v_policy_id NUMBER;
  BEGIN
    BEGIN
      v_policy_id := get_recover_policy_id(par_policy_id);

      SELECT act_date
        INTO v_act_date
        FROM (SELECT trunc(ds.start_date) AS act_date
                FROM ins.doc_status     ds
                    ,ins.doc_status_ref dsr
               WHERE ds.document_id = v_policy_id
                 AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief = 'CURRENT'
               ORDER BY ds.start_date ASC)
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        v_act_date := '01.01.1900';
    END;
    RETURN v_act_date;
  END;

  --���������� id ������� ��������� ������ ��������������
  FUNCTION get_recover_policy_id(par_policy_id NUMBER) RETURN NUMBER IS
    v_policy_id NUMBER;
  BEGIN
    BEGIN
      SELECT policy_id
        INTO v_policy_id
        FROM (SELECT pp_.policy_id
                FROM ins.p_policy            pp
                    ,ins.p_policy            pp_
                    ,ins.p_pol_addendum_type tp_
                    ,ins.t_addendum_type     tt_
                    ,ins.doc_status          ds_
                    ,ins.doc_status_ref      dsr_
               WHERE pp.policy_id = par_policy_id
                 AND pp_.pol_header_id = pp.pol_header_id
                 AND pp_.policy_id != pp.policy_id
                 AND pp_.version_num > pp.version_num
                 AND pp_.policy_id = tp_.p_policy_id
                 AND tp_.t_addendum_type_id = tt_.t_addendum_type_id
                 AND tt_.brief IN
                     ('RECOVER_MAIN', 'FULL_POLICY_RECOVER', 'WRONGFUL_TERM_POLICY_RECOVER')
                 AND ds_.document_id = pp_.policy_id
                 AND ds_.doc_status_ref_id = dsr_.doc_status_ref_id
                 AND dsr_.brief = 'CURRENT'
               ORDER BY pp_.version_num)
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        v_policy_id := NULL;
    END;
    RETURN v_policy_id;
  END;

  FUNCTION get_contract_sign(par_policy_id NUMBER) RETURN VARCHAR2 IS
  BEGIN
    NULL;

  END;

  --��������� ����� ��. ������ �����������
  FUNCTION create_quit_journal
  (
    par_date_begin     DATE
   ,par_date_end       DATE
   ,par_regulated_loss VARCHAR2 -- ��������������� ������
   ,par_claimed_loss   VARCHAR2 -- ���������� ������
   ,par_renew_quit     VARCHAR2 -- �������������� � ����������� �� ��������� ��������� �������
   ,par_setoff_fin     VARCHAR2 -- �����/���������� ��������
  ) RETURN NUMBER IS

    PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    DELETE FROM tmp_quit_journal;
    IF par_regulated_loss = '��'
    THEN
      --  1. ��������������� ������ (����� �������������� �� ���� ������� ������������)
      -- ������� ��������� �� ������� �� ������������ � �� �����������. ����� ��� ��������
      INSERT INTO tmp_quit_journal
        SELECT /*+ LEADING (pp)*/
         pp.issuer_return_date
        ,pp.policy_id
        ,pp.p_cover_id
        ,pp.t_prod_line_option_id
        ,pp.policy_id
        ,0
        ,'QUIT_SETTLED'
        ,0
        --          ,'��������������� ������'
          FROM (SELECT /*+ LEADING(pd pp ph) USE_NL(pd pp ph) NO_MERGE*/
                 pd.issuer_return_date
                ,pp.policy_id
                ,pc.p_cover_id
                ,pc.t_prod_line_option_id
                  FROM ins.p_policy           pp
                      ,ins.p_pol_decline      pd
                      ,ins.as_asset           se
                      ,ins.p_cover            pc
                      ,ins.p_cover_decline    pcd --������ ������� 225904: ������ �����������
                      ,ins.t_prod_line_option plo --������ ������� 225904: ������ �����������
                 WHERE pp.policy_id = pd.p_policy_id
                      --������ ��������������� 225904: ������ �����������
                      --and pp.policy_id        = se.p_policy_id
                   AND se.as_asset_id = pc.as_asset_id
                   AND trunc(pd.issuer_return_date) BETWEEN par_date_begin AND par_date_end
                      --������ ������� 225904: ������ �����������
                   AND pcd.p_pol_decline_id = pd.p_pol_decline_id
                   AND se.as_asset_id = pcd.as_asset_id
                   AND plo.product_line_id = pcd.t_product_line_id
                   AND plo.id = pc.t_prod_line_option_id
                --
                ) pp
         WHERE EXISTS (SELECT NULL
                  FROM ins.doc_status     ds
                      ,ins.doc_status_ref dfr
                      ,ins.doc_status_ref dto
                 WHERE ds.document_id = pp.policy_id
                   AND ds.src_doc_status_ref_id = dfr.doc_status_ref_id
                   AND dfr.brief = 'TO_QUIT'
                   AND ds.doc_status_ref_id = dto.doc_status_ref_id
                   AND dto.brief = 'TO_QUIT_CHECK_READY');
    END IF;

    IF par_claimed_loss = '��'
    THEN
      -- 2.  ����������������� (����������) ������ (����� �������������� �� ���� ����)
      -- ������� ��������� �� ������� �� ������������ � �� �����������. ����� ��� ��������
      INSERT INTO tmp_quit_journal
        SELECT /*+ LEADING (pp)*/
         pp.act_date
        ,pp.policy_id
        ,pp.p_cover_id
        ,pp.t_prod_line_option_id
        ,pp.policy_id
        ,1
        ,'QUIT_NONSETTLED'
        ,0
        --          ,'����������������� (����������) ������'
          FROM (SELECT /*+ LEADING(pd pp ph) USE_NL(pd pp ph) NO_MERGE*/
                 pd.act_date
                ,pp.policy_id
                ,pc.p_cover_id
                ,pc.t_prod_line_option_id
                  FROM ins.p_policy           pp
                      ,ins.p_pol_decline      pd
                      ,ins.as_asset           se
                      ,ins.p_cover            pc
                      ,ins.p_cover_decline    pcd --������ ������� 225904: ������ �����������
                      ,ins.t_prod_line_option plo --������ ������� 225904: ������ �����������
                 WHERE pp.policy_id = pd.p_policy_id
                   AND (pd.issuer_return_date IS NULL OR trunc(pd.issuer_return_date) > par_date_end)
                      --������ ��������������� 225904: ������ �����������
                      --and pp.policy_id        = se.p_policy_id
                   AND se.as_asset_id = pc.as_asset_id
                   AND trunc(pd.act_date) BETWEEN par_date_begin AND par_date_end
                      --������ ������� 225904: ������ �����������
                   AND pcd.p_pol_decline_id = pd.p_pol_decline_id
                   AND se.as_asset_id = pcd.as_asset_id
                   AND plo.product_line_id = pcd.t_product_line_id
                   AND plo.id = pc.t_prod_line_option_id
                --
                ) pp
         WHERE EXISTS (SELECT NULL
                  FROM ins.doc_status     ds
                      ,ins.doc_status_ref dfr
                      ,ins.doc_status_ref dto
                 WHERE ds.document_id = pp.policy_id
                   AND ds.src_doc_status_ref_id = dfr.doc_status_ref_id
                   AND dfr.brief = 'TO_QUIT'
                   AND ds.doc_status_ref_id = dto.doc_status_ref_id
                   AND dto.brief = 'TO_QUIT_CHECK_READY');
    END IF;

    IF par_renew_quit = '��'
    THEN
      -- 3.  �������������� � ����������� �� ��������� ��������� �������.
      INSERT INTO tmp_quit_journal
        WITH renew AS
         (SELECT pp.policy_id
                ,pp.act_date
                ,pp.brief
                ,pp.version_num
                ,pp.pol_header_id
                ,next_ver_brief
            FROM (SELECT /*+ LEADING(tt tp pp) USE_NL(tt tp) USE_HASH(tp pp) INDEX(pp PK_P_POLICY) NO_MERGE*/
                   pp.policy_id
                  ,trunc(ds.start_date) AS act_date
                  ,row_number() over(PARTITION BY pp.policy_id ORDER BY pp.policy_id, ds.start_date DESC) AS rn
                  ,tt.brief
                  ,pp.version_num
                  ,pp.pol_header_id
                  ,(SELECT dsr_f.brief
                      FROM ins.ven_p_policy   pp_f
                          ,ins.doc_status_ref dsr_f
                     WHERE pp_f.pol_header_id = pp.pol_header_id
                       AND dsr_f.doc_status_ref_id = pp_f.doc_status_ref_id
                       AND pp_f.version_num = pp.version_num - 1

                    ) next_ver_brief
                    FROM ins.p_policy            pp
                        ,ins.p_pol_addendum_type tp
                        ,ins.t_addendum_type     tt
                        ,ins.doc_status          ds
                        ,ins.doc_status_ref      dsr
                   WHERE pp.policy_id = tp.p_policy_id
                     AND tp.t_addendum_type_id = tt.t_addendum_type_id
                     AND tt.brief IN
                         ('RECOVER_MAIN', 'FULL_POLICY_RECOVER', 'WRONGFUL_TERM_POLICY_RECOVER')
                     AND ds.document_id = pp.policy_id
                     AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                     AND dsr.brief = 'CURRENT'
                     AND trunc(ds.start_date) BETWEEN par_date_begin AND
                         par_date_end + 1 - 1 / 24 / 3600) pp
           WHERE pp.rn = 1)
        SELECT /* + LEADING(pp se pc)*/
         pp.act_date
        ,pp.policy_id
        ,pc.p_cover_id
        ,pc.t_prod_line_option_id
        ,pd.policy_id
        ,2
        ,pp.brief
        ,0
        --          ,'�������������� � ����������� (��������������)'
          FROM renew        pp
              ,ins.as_asset se
              ,ins.p_cover  pc
              ,ins.p_policy pd
         WHERE pp.policy_id = se.p_policy_id
           AND se.as_asset_id = pc.as_asset_id
           AND pp.pol_header_id = pd.pol_header_id(+)
              --����������� ������ 226638: ����� <������ �����������>
              --and pp.version_num - 1 = pd.version_num (+)
              --������� ������ 226638: ����� <������ �����������>
           AND ((pd.version_num = pp.version_num - 1 AND pp.next_ver_brief != 'RECOVER_DENY') OR
               (pd.version_num = pp.version_num - 2 AND pp.next_ver_brief = 'RECOVER_DENY'))

        UNION ALL
        -- ��������������� ������ (����� �������������� �� ���� ������� ������������)
        -- �� ������ �������� � ������� �� �����
        SELECT /* + LEADING (re pp ds)*/
         pp.issuer_return_date
        ,pp.policy_id
        ,pp.p_cover_id
        ,pp.t_prod_line_option_id
        ,pp.policy_id /*re.policy_id*/
        ,3
        ,'QUIT_SETTLED_PAST'
        ,0
        --          ,'�������������� � ����������� (��������������� ������)'
          FROM (SELECT /* + LEADING(pd pp ph) USE_NL(pd pp ph) NO_MERGE*/
                 pd.issuer_return_date
                ,pp.policy_id
                ,pc.p_cover_id
                ,pc.t_prod_line_option_id
                ,pp.version_num
                ,pp.pol_header_id
                  FROM ins.p_policy           pp
                      ,ins.p_pol_decline      pd
                      ,ins.as_asset           se
                      ,ins.p_cover            pc
                      ,ins.p_cover_decline    pcd --������ ������� 225904: ������ �����������
                      ,ins.t_prod_line_option plo --������ ������� 225904: ������ �����������
                 WHERE pp.policy_id = pd.p_policy_id
                      --������ ��������������� 225904: ������ �����������
                      --and pp.policy_id          = se.p_policy_id
                   AND se.as_asset_id = pc.as_asset_id
                   AND trunc(pd.issuer_return_date) < par_date_begin
                      --������ ������� 225904: ������ �����������
                   AND pcd.p_pol_decline_id = pd.p_pol_decline_id
                   AND se.as_asset_id = pcd.as_asset_id
                   AND plo.product_line_id = pcd.t_product_line_id
                   AND plo.id = pc.t_prod_line_option_id
                --
                ) pp
              ,renew re
         WHERE pp.pol_header_id = re.pol_header_id
              --����������� ������ 226638: ����� <������ �����������>
              --and pp.version_num   = re.version_num-1
              --������� ������ 226638: ����� <������ �����������>
           AND ((pp.version_num = re.version_num - 1 AND re.next_ver_brief != 'RECOVER_DENY') OR
               (pp.version_num = re.version_num - 2 AND re.next_ver_brief = 'RECOVER_DENY'))
        --
        UNION ALL
        -- ����������������� (����������) ������ (����� �������������� �� ���� ����)
        SELECT /* + LEADING(re pp)*/
         pp.act_date
        ,pp.policy_id
        ,pp.p_cover_id
        ,pp.t_prod_line_option_id
        ,pp.policy_id /*re.policy_id*/
        ,4
        ,'QUIT_NONSETTLED_PAST'
        ,0
        --          ,'�������������� � ����������� (����������������� ������)'
          FROM (SELECT /* + LEADING(pd pp ph) USE_NL(pd pp ph) NO_MERGE*/
                 pd.act_date
                ,pp.policy_id
                ,pc.p_cover_id
                ,pc.t_prod_line_option_id
                ,pp.version_num
                ,pp.pol_header_id
                  FROM ins.p_policy           pp
                      ,ins.p_pol_decline      pd
                      ,ins.as_asset           se
                      ,ins.p_cover            pc
                      ,ins.p_cover_decline    pcd --������ ������� 225904: ������ �����������
                      ,ins.t_prod_line_option plo --������ ������� 225904: ������ �����������
                 WHERE pp.policy_id = pd.p_policy_id
                      --������ ��������������� 225904: ������ �����������
                      --and pp.policy_id        = se.p_policy_id
                   AND (pd.issuer_return_date IS NULL OR trunc(pd.issuer_return_date) > par_date_end)
                   AND se.as_asset_id = pc.as_asset_id
                   AND trunc(pd.act_date) < par_date_begin
                      --������ ������� 225904: ������ �����������
                   AND pcd.p_pol_decline_id = pd.p_pol_decline_id
                   AND se.as_asset_id = pcd.as_asset_id
                   AND plo.product_line_id = pcd.t_product_line_id
                   AND plo.id = pc.t_prod_line_option_id
                --
                ) pp
              ,renew re
         WHERE pp.pol_header_id = re.pol_header_id
              --����������� ������ 226638: ����� <������ �����������>
              --and pp.version_num   = re.version_num-1
              --������� ������ 226638: ����� <������ �����������>
           AND ((pp.version_num = re.version_num - 1 AND re.next_ver_brief != 'RECOVER_DENY') OR
               (pp.version_num = re.version_num - 2 AND re.next_ver_brief = 'RECOVER_DENY'));
      --
    END IF;

    IF par_setoff_fin = '��'
    THEN
      -- 4. �����/ ���������� ��������
      INSERT INTO tmp_quit_journal
        SELECT /*+ LEADING(pp) */
         pp.act_date
        ,pp.policy_id
        ,pc.p_cover_id
        ,pc.t_prod_line_option_id
        ,NULL
        ,5
        ,'UNDERWRITING_CHANGE'
        ,pc_.fee - pc.fee
        --          ,'�����/ ���������� ��������'
          FROM (SELECT /*+ LEADING(tt tp pp ph dsr ds) USE_NL(tt tp) USE_HASH(tp pp) INDEX(pp PK_P_POLICY) NO_MERGE */
                 pp.policy_id
                ,trunc(ds.start_date) AS act_date
                ,row_number() over(PARTITION BY pp.policy_id ORDER BY pp.policy_id, ds.start_date DESC) AS rn
                ,pp.version_num
                ,pp.pol_header_id
                  FROM ins.p_policy            pp
                      ,ins.p_pol_addendum_type tp
                      ,ins.t_addendum_type     tt
                      ,ins.doc_status          ds
                 WHERE pp.policy_id = tp.p_policy_id
                   AND tp.t_addendum_type_id = tt.t_addendum_type_id
                   AND tt.brief = 'UNDERWRITING_CHANGE'
                   AND ds.document_id = pp.policy_id
                   AND trunc(ds.start_date) BETWEEN par_date_begin AND par_date_end + 1 - 1 / 24 / 3600
                   AND ds.start_date IN (SELECT MAX(ds_.start_date)
                                           FROM ins.doc_status     ds_
                                               ,ins.doc_status_ref dsr
                                          WHERE ds_.document_id = ds.document_id
                                            AND ds_.doc_status_ref_id = dsr.doc_status_ref_id
                                            AND dsr.brief = 'CONCLUDED')) pp
              ,ins.as_asset se
              ,ins.p_cover pc
              ,ins.status_hist sh
               -- �������� �� ���������� ������ �� �����
              ,ins.p_policy pp_
              ,ins.as_asset se_
              ,ins.p_cover  pc_
         WHERE rn = 1
           AND pp.policy_id = se.p_policy_id
           AND se.as_asset_id = pc.as_asset_id
           AND pc.status_hist_id = sh.status_hist_id
           AND pp_.policy_id = se_.p_policy_id
           AND se_.as_asset_id = pc_.as_asset_id
           AND pp_.pol_header_id = pp.pol_header_id
           AND pp_.version_num = pp.version_num - 1
           AND pc_.t_prod_line_option_id = pc.t_prod_line_option_id
           AND (sh.brief = 'DELETED' OR pc_.fee > pc.fee)
        UNION ALL
        /* ��������� ������� � ����� � ���. ����������; ���� ������ ���. ������� �� ������ �������� � ���������*/
        SELECT /*+ LEADING(pp) */
         pp.act_date
        ,pp.policy_id
        ,pc.p_cover_id
        ,pc.t_prod_line_option_id
        ,NULL
        ,5
        ,'FIN_WEEK'
        ,0
        --          ,'�����/ ���������� ��������'
          FROM (SELECT /*+ LEADING(tt tp pp ph dsr ds) USE_NL(tt tp) USE_HASH(tp pp) INDEX(pp PK_P_POLICY) NO_MERGE */
                 pp.policy_id
                ,trunc(ds.start_date) AS act_date
                ,row_number() over(PARTITION BY pp.policy_id ORDER BY pp.policy_id, ds.start_date DESC) AS rn
                ,pp.version_num
                ,ph.policy_header_id
                ,ph.start_date
                  FROM ins.p_pol_header        ph
                      ,ins.p_policy            pp
                      ,ins.p_pol_addendum_type tp
                      ,ins.t_addendum_type     tt
                      ,ins.doc_status          ds
                 WHERE ph.policy_header_id = pp.pol_header_id
                   AND pp.policy_id = tp.p_policy_id
                   AND tp.t_addendum_type_id = tt.t_addendum_type_id
                   AND tt.brief = 'FIN_WEEK'
                   AND ds.document_id = pp.policy_id
                   AND trunc(ds.start_date) BETWEEN par_date_begin AND par_date_end + 1 - 1 / 24 / 3600
                   AND ds.start_date IN (SELECT MAX(ds_.start_date)
                                           FROM ins.doc_status     ds_
                                               ,ins.doc_status_ref dsr
                                          WHERE ds_.document_id = ds.document_id
                                            AND ds_.doc_status_ref_id = dsr.doc_status_ref_id
                                               /*and dsr.brief             in ('CONCLUDED','CURRENT')*/
                                            AND dsr.brief = 'CONCLUDED')) pp
              ,ins.as_asset se
              ,ins.p_cover pc
              ,ins.status_hist sh
         WHERE rn = 1
           AND MOD(MONTHS_BETWEEN(pp.start_date, pp.act_date), 12) != 0
           AND pp.policy_id = se.p_policy_id
           AND se.as_asset_id = pc.as_asset_id
           AND pc.status_hist_id = sh.status_hist_id
           AND (sh.brief = 'DELETED' OR
               -- �������� �� ���������� ������ �� �����
               EXISTS (SELECT NULL
                         FROM ins.p_policy pp_
                             ,ins.as_asset se_
                             ,ins.p_cover  pc_
                        WHERE pp_.policy_id = se_.p_policy_id
                          AND se_.as_asset_id = pc_.as_asset_id
                          AND pp_.pol_header_id = pp.policy_header_id
                          AND pp_.version_num = pp.version_num - 1
                          AND pc_.t_prod_line_option_id = pc.t_prod_line_option_id
                          AND pc_.fee > pc.fee));
    END IF;

    --�������� ��������� � ������� "������ ����� �����������", �.�. ��� �� ����� �������� � ����� 17.3.2015 ������ �.
    DELETE FROM tmp_quit_journal t
     WHERE EXISTS (SELECT NULL
              FROM document       ds
                  ,doc_status_ref dsr
             WHERE ds.document_id = t.policy_id
               AND ds.doc_status_ref_id = dsr.doc_status_ref_id
               AND dsr.brief = 'DECLINE_CALCULATION');

    COMMIT;

    RETURN 0;

  END create_quit_journal;

BEGIN
  NULL;
END pkg_quit_journal_rep;
/

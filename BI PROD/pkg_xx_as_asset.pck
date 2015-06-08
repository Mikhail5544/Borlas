CREATE OR REPLACE PACKAGE PKG_XX_AS_ASSET IS

  TYPE t_product_line_info IS RECORD(
     BRIEF                 VARCHAR2(100 BYTE)
    ,DESCRIPTION           VARCHAR2(255 BYTE)
    ,ID                    NUMBER
    ,FOR_PREMIUM           NUMBER(1)
    ,SORT_ORDER            NUMBER(4)
    ,PRODUCT_ID            NUMBER
    ,ASSET_ID              NUMBER
    ,FOR_RE                NUMBER
    ,PLT_DESC              VARCHAR2(30 BYTE)
    ,P_COVER_ID            NUMBER
    ,AS_ASSET_ID           NUMBER
    ,T_PROD_LINE_OPTION_ID NUMBER
    ,START_DATE            DATE
    ,END_DATE              DATE
    ,INS_AMOUNT            NUMBER(11, 2)
    ,PREMIUM               NUMBER(11, 2)
    ,TARIFF                NUMBER
    ,T_DEDUCTIBLE_TYPE_ID  NUMBER
    ,T_DEDUCT_VAL_TYPE_ID  NUMBER
    ,DEDUCTIBLE_VALUE      NUMBER
    ,STATUS_HIST_ID        NUMBER
    ,ENT_ID                NUMBER(6)
    ,FILIAL_ID             NUMBER(6)
    ,OLD_PREMIUM           NUMBER(11, 2)
    ,COMPENSATION_TYPE     NUMBER
    ,FEE                   NUMBER
    ,IS_HANDCHANGE_AMOUNT  NUMBER(1)
    ,IS_HANDCHANGE_PREMIUM NUMBER(1)
    ,IS_HANDCHANGE_TARIFF  NUMBER(1)
    ,IS_HANDCHANGE_DEDUCT  NUMBER(1)
    ,DECLINE_DATE          DATE
    ,DECLINE_SUMM          NUMBER
    ,IS_DECLINE_CHARGE     NUMBER(1)
    ,IS_DECLINE_COMISSION  NUMBER(1)
    ,IS_HANDCHANGE_DECLINE NUMBER(1)
    ,IS_AGGREGATE          NUMBER(1)
    ,INS_PRICE             NUMBER
    ,EXT_ID                VARCHAR2(50 BYTE)
    ,IS_PROPORTIONAL       NUMBER(1)
    ,RVB_VALUE             NUMBER(6, 5)
    ,K_COEF                NUMBER(6, 5)
    ,S_COEF                NUMBER(6, 5)
    ,NORMRATE_VALUE        NUMBER(6, 5)
    ,COMMENTS              VARCHAR2(500 BYTE)
    ,INSURED_AGE           NUMBER(3)
    ,ACCUM_END_AGE         NUMBER(3)
    ,PREMIUM_ALL_SROK      NUMBER(11, 2)
    ,PREMIA_BASE_TYPE      NUMBER(1)
    ,ADDED_SUMM            NUMBER
    ,PAYED_SUMM            NUMBER
    ,DEBT_SUMM             NUMBER
    ,RETURN_SUMM           NUMBER
    ,ACCUM_PERIOD_END_AGE  NUMBER
    ,IS_AVTOPROLONGATION   NUMBER
    ,NETTO_TARIFF          NUMBER
    ,K_COEF_M              NUMBER
    ,K_COEF_NM             NUMBER
    ,S_COEF_M              NUMBER
    ,S_COEF_NM             NUMBER
    ,DECLINE_PARTY_ID      NUMBER
    ,DECLINE_REASON_ID     NUMBER
    ,PERIOD_ID             NUMBER(9)
    ,TARIFF_NETTO          NUMBER
    ,IS_HANDCHANGE_FEE     NUMBER(1)
    ,IMAGING               VARCHAR2(10 BYTE)
    ,PRODUCT_LINE_ID       NUMBER(9));
  TYPE tbl_product_line_info IS TABLE OF t_product_line_info;

  -- Author  : Marchuk A.
  -- Created : 01.10.2007
  -- Purpose : Функции для обеспечения функционирования формы AS_ASSURED_LIFE_REN

  FUNCTION product_line_info(p_as_asset_id IN NUMBER) RETURN tbl_product_line_info
    PARALLEL_ENABLE
    PIPELINED;
  PROCEDURE set_as_asset_id(p_as_asset_id IN NUMBER);
  FUNCTION get_as_asset_id RETURN NUMBER;

END;
/
CREATE OR REPLACE PACKAGE BODY PKG_XX_AS_ASSET IS
  p_p_as_asset_id NUMBER;
  -- Author  : Marchuk A.
  -- Created : 01.10.2007
  -- Purpose : Функции для обеспечения функционирования формы AS_ASSURED_LIFE_REN

  FUNCTION product_line_info(p_as_asset_id IN NUMBER) RETURN tbl_product_line_info
    PARALLEL_ENABLE
    PIPELINED IS
    CURSOR c_info IS
      SELECT BRIEF
            ,PL.DESCRIPTION
            ,ID
            ,FOR_PREMIUM
            ,SORT_ORDER
            ,PL.PRODUCT_ID
            ,ASSET_ID
            ,FOR_RE
            ,PLT_DESC
            ,P_COVER_ID
            ,PC.AS_ASSET_ID
            ,T_PROD_LINE_OPTION_ID
            ,PC.START_DATE
            ,PC.END_DATE
            ,PC.INS_AMOUNT
            ,PC.PREMIUM
            ,PC.TARIFF
            ,PC.T_DEDUCTIBLE_TYPE_ID
            ,PC.T_DEDUCT_VAL_TYPE_ID
            ,PC.DEDUCTIBLE_VALUE
            ,PC.STATUS_HIST_ID
            ,PC.ENT_ID
            ,PC.FILIAL_ID
            ,OLD_PREMIUM
            ,COMPENSATION_TYPE
            ,PC.FEE
            ,IS_HANDCHANGE_AMOUNT
            ,IS_HANDCHANGE_PREMIUM
            ,IS_HANDCHANGE_TARIFF
            ,IS_HANDCHANGE_DEDUCT
            ,PC.DECLINE_DATE
            ,PC.DECLINE_SUMM
            ,IS_DECLINE_CHARGE
            ,IS_DECLINE_COMISSION
            ,IS_HANDCHANGE_DECLINE
            ,IS_AGGREGATE
            ,PC.INS_PRICE
            ,PC.EXT_ID
            ,IS_PROPORTIONAL
            ,RVB_VALUE
            ,K_COEF
            ,S_COEF
            ,NORMRATE_VALUE
            ,COMMENTS
            ,INSURED_AGE
            ,ACCUM_PERIOD_END_AGE ACCUM_END_AGE
            ,PREMIUM_ALL_SROK
            ,PC.PREMIA_BASE_TYPE
            ,PC.ADDED_SUMM
            ,PC.PAYED_SUMM
            ,PC.DEBT_SUMM
            ,PC.RETURN_SUMM
            ,ACCUM_PERIOD_END_AGE
            ,IS_AVTOPROLONGATION
            ,NETTO_TARIFF
            ,K_COEF_M
            ,K_COEF_NM
            ,S_COEF_M
            ,S_COEF_NM
            ,PC.DECLINE_PARTY_ID
            ,PC.DECLINE_REASON_ID
            ,PC.PERIOD_ID
            ,TARIFF_NETTO
            ,IS_HANDCHANGE_FEE
            ,IMAGING
            ,PRODUCT_LINE_ID
        FROM ((SELECT pl.brief
                     ,pl.description
                     ,pl.ID
                     ,pl.for_premium
                     ,pl.sort_order
                     ,pv.product_id
                     ,a.as_asset_id asset_id
                     ,pkg_re_bordero.cover_reins(pl.ID, a.as_asset_id) for_re
                     ,plt.presentation_desc plt_desc
                 FROM t_product_version   pv
                     ,t_product_ver_lob   pvl
                     ,t_product_line      pl
                     ,t_product_line_type plt
                     ,t_as_type_prod_line atpl
                     ,as_asset            a
                     ,p_asset_header      pah
                WHERE pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                  AND pv.t_product_version_id = pvl.product_version_id
                  AND pl.visible_flag = 1
                  AND pl.ID = atpl.product_line_id
                  AND a.p_asset_header_id = pah.p_asset_header_id
                  AND atpl.asset_common_type_id = pah.t_asset_type_id
                  AND plt.product_line_type_id = pl.product_line_type_id
                  AND a.ins_var_id IS NULL) UNION
              (SELECT pl.brief
                     ,pl.description
                     ,pl.t_prod_line_dms_id ID
                     ,pl.for_premium
                     ,pl.sort_order
                     ,(SELECT product_id FROM ven_t_product WHERE brief = 'ДМС')
                     ,a.as_asset_id asset_id
                     ,pkg_re_bordero.cover_reins(pl.t_prod_line_dms_id, a.as_asset_id) for_re
                     ,plt.presentation_desc plt_desc
                 FROM ven_t_prod_line_dms pl
                     ,t_product_line_type plt
                     ,as_asset            a
                WHERE pl.p_policy_id = a.P_POLICY_ID
                  AND plt.product_line_type_id = pl.PRODUCT_LINE_TYPE_ID)) pl
            ,(SELECT pc.*
                    ,sh.imaging
                    ,plo.product_line_id
                FROM p_cover            pc
                    ,t_prod_line_option plo
                    ,ven_status_hist    sh
               WHERE pc.t_prod_line_option_id = plo.ID
                 AND pc.status_hist_id = sh.status_hist_id) pc
            ,p_pol_header ph
            ,p_policy pp
            ,as_asset aa
       WHERE 1 = 1
         AND aa.as_asset_id = p_as_asset_id
         AND pp.policy_id = aa.p_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pl.asset_id = aa.as_asset_id
         AND pl.product_id = ph.product_id
         AND pc.product_line_id(+) = pl.ID
         AND pc.as_asset_id(+) = p_as_asset_id
         AND (aa.as_asset_id IS NOT NULL OR pl.ID IS NULL);
  BEGIN
    FOR i IN c_info
    LOOP
      PIPE ROW(i);
    END LOOP;
    RETURN;
  END;

  PROCEDURE set_as_asset_id(p_as_asset_id IN NUMBER) IS
  BEGIN
    p_p_as_asset_id := p_as_asset_id;
  END;
  FUNCTION get_as_asset_id RETURN NUMBER IS
  BEGIN
    RETURN p_p_as_asset_id;
  END;
END;
/

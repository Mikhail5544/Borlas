CREATE OR REPLACE PACKAGE Pkg_Asset IS

  --test svn
  /**
  * ����� ������������ �������� �����������
  * @author Alexander Kalabukhov
  * @version 1
  */

  /**
  * �� ������� ����������� �������� '�����'
  */
  status_hist_id_new NUMBER;
  /**
  * �� ������� ����������� �������� '�����������'
  */
  status_hist_id_curr NUMBER;
  /**
  * �� ������� ����������� �������� '������'
  */
  status_hist_id_del NUMBER;

  /**
  * ������� � ���������������� ������ �����������
  * @author Alexander Kalabukhov
  * @param p_ref_id �� ������
  * @param p_p_asset_header_id �� ��������� ������� �����������
  * @param p_t_asset_type_id �� ���� ������� �����������
  */
  --  function create_as_asset(p_ref_id in number, p_p_asset_header_id in number, p_t_asset_type_id in number) return number;

  /**
  * ����������� ������ ����������� �� ������ ������
  * ���������� ��� ������� �����������, �� �����������, ������� ������ "��������".
  * @author Alexander Kalabukhov
  * @param p_old_id �� ������ ���������
  * @param p_new_id �� ������ ���������
  */
  PROCEDURE copy_as_asset
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  );

  /**
  * ����������� ������ ����������� �� ������ ������
  * ���������� ��� ������� �����������, �� �����������, ������� ������ "��������".
  * @author Alexander Kalabukhov
  * @param p_old_id �� ������ ���������
  * @param p_new_id �� ������ ���������
  * @param p_new_asset_type_id �� ���� �������
  */
  PROCEDURE copy_as_asset
  (
    p_old_id            IN NUMBER
   ,p_new_id            IN NUMBER
   ,p_new_asset_type_id IN NUMBER
  );

  /**
  * ����������� ��
  * @author Alexander Kalabukhov
  * @param p_old_id �� �� ���������
  * @param p_new_id �� �� ���������
  */
  --procedure copy_as_vehicle(p_old_id in number, p_new_id in number);

  /**
  * ����������� ������� ������������� ������� �����������
  * @author Alexander Kalabukhov
  * @param p_old_id �� ������� ����������� ���������
  * @param p_new_id �� ������� ����������� ���������
  */
  PROCEDURE copy_as_asset_per
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  );

  /**
  * ����������� ��������� �� ��
  * @author Alexander Kalabukhov
  * @param p_old_id �� �� ���������
  * @param p_new_id �� �� ���������
  */
  PROCEDURE copy_as_vehicle_driver
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  );

  /**
  * ����������� ������ � ��� ������������ ��
  * @author Alexander Kalabukhov
  * @param p_old_id �� �� ���������
  * @param p_new_id �� �� ���������
  */
  PROCEDURE copy_as_vehicle_stuff
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  );

  /**
  * ����������� ������ �� ������������� �������������� �������� ��
  * @author Alexander Kalabukhov
  * @param p_old_id �� �� ���������
  * @param p_new_id �� �� ���������
  */
  PROCEDURE copy_as_vehicle_device
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  );

  /**
  * ���������� ������� ��������
  * @author Alexander Kalabukhov
  * @param p_p_policy_id �� ������
  * @param p_cn_person_id �� ����������� ���� (��������)
  * @return ������� ��������
  */
  FUNCTION calc_driver_age
  (
    p_p_policy_id  IN NUMBER
   ,p_cn_person_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� ���� ��������
  * @author Alexander Kalabukhov
  * @param par_per
  * @param par_pp
  * @return ���� ��������
  */
  FUNCTION get_staj_driver
  (
    par_per IN NUMBER
   ,par_pp  IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� �� ���� p_date ���������� ��������� �� � �� � ������ ������
  * @param p_asset_header �� ��������� ������� �����������
  * @param p_date ���� ��������
  * @return ���������� ���������
  */
  FUNCTION get_price_asset
  (
    p_asset_header IN NUMBER
   ,p_date         IN DATE
  ) RETURN NUMBER;

  /**
  * ���������� �� ���� p_date ���������� ��������� �� � ������ ������
  * @param p_asset_header �� ��������� ������� �����������
  * @param p_date ���� ��������
  * @return ���������� ��������� ��
  */
  FUNCTION get_price_av_stuff
  (
    p_asset_header IN NUMBER
   ,p_date         IN DATE
  ) RETURN NUMBER;

  /**
  *
  * @author Alexander Kalabukhov
  * @param p_p_policy_id �� ������
  * @param p_cn_person_id �� ����������� ���� (��������)
  * @return
  */
  FUNCTION calc_driver_start_date
  (
    p_p_policy_id  IN NUMBER
   ,p_cn_person_id IN NUMBER
  ) RETURN DATE;

  /**
  * ��������� �������� � ��������� ����� � ��������
  * @author Alexander Kalabukhov
  * @param p_val �������� � �.�.
  * @return �������� � ���
  */
  FUNCTION kw_to_hp(p_val IN NUMBER) RETURN NUMBER;

  /**
  * ��������� ������ ����������� �� ������
  * @param p_p_policy_id �� ������
  * @param p_as_asset_id �� ������� �����������
  */
  PROCEDURE exclude_as_asset
  (
    p_p_policy    NUMBER
   ,p_as_asset_id NUMBER
  );

  /**
  * ��������� �������� ����� ��������� ������� �����������
  * @author Denis Ivanov
  * @param p_as_asset_id �� ������� ������������
  */
  PROCEDURE after_asset_update(p_as_asset_id NUMBER);

  /**
  * ��������� �������� � ��������� ����� � ��������
  * @author Alexander Kalabukhov
  * @param p_val �������� � �.�.
  * @return �������� � ���
  */
  FUNCTION get_card_nr RETURN VARCHAR2;

  /**
  * ����� ������� �����������
  * @author Alexander Kalabukhov
  * @param p_asset_id �� ������� �����������
  * @return ����� ������� �����������
  */
  FUNCTION get_address(p_asset_id NUMBER) RETURN VARCHAR2;

  /**
  * ������ ���������� � ���������� ��� ������������� ��������
  * @author Filipp Ganichev
  * @param p_as_vehicle_id�� ������� �����������
  * @return ������ ���������� � ���������� ��� ������������� ��������
  */
  FUNCTION get_as_vehicle_drivers(p_as_vehicle_id NUMBER) RETURN VARCHAR2;

  /**
  * @param p_tst
  * @param p_pol_id
  * @param p_if
  * @return
  */
  FUNCTION get_note
  (
    p_tst    NUMBER
   ,p_pol_id NUMBER
   ,p_if     NUMBER
  ) RETURN VARCHAR2;

  /**
  * �������������� ������� (��������� ��):
  *     p_res=1 ������� ������� (������������ �� ����) - ��/���,
  *        p_res=2 ��������,
  *        p_res=3 ��������� �����/���������
  * @author Protsvetov Evgeniy
  * @param p_policy_header_id �� ��������� �������� �����������
  *           p_type ��� �������, ���. ���������� ������������
  *        p_res ��� ����������, ������� ���������� �������
  * @return ������� �������,��������,��������� �����/���������
  */
  FUNCTION get_property_UL
  (
    p_policy_header_id NUMBER
   ,p_type             NUMBER
   ,p_res              NUMBER DEFAULT 1
  ) RETURN VARCHAR2;

  /**
  * �������� ������������ VIN
  * @author Vitaly Ustinov
  * @param p_vin ����������� VIN
  * @param p_error_msg out ����� ������
  * @return true/flase
  */
  FUNCTION check_vin
  (
    p_vin       VARCHAR2
   ,p_error_msg OUT VARCHAR2
  ) RETURN BOOLEAN;

  /**
  * �������� ������� ���� ���������� ��������� � ������ ���������� � ����������
  * @author �������
  * @param p_as_vehicle_id �� ������������� ��������
  * @param p_contact_id �� ��������
  * @throw ���������� ���� ���� ���������� ��������
  */
  PROCEDURE check_duplicate_drivers
  (
    p_as_vehicle_id NUMBER
   ,p_contact_id    NUMBER DEFAULT NULL
  );

  /**
  * �������� ������������ ������� ��������� � ��������� �� ���������
  * @author �������
  * @param p_claim_header_id �� ��������� ���������
  * @throw ���������� ���� ������ ����� ������ �������� ��� �������� ��� � ������ ���������� � ���������� ��
  */
  PROCEDURE check_claim_driver(p_claim_header_id NUMBER);

  /**
  * ������� ������ �������������� � ������
  * @author �������
  * @param p_pol_id �� ������
  * @param p_contact_id �� ��������
  * @param p_work_group_id - �� ������ ���������
  * @return �� ���������������
  */
  FUNCTION create_as_assured
  (
    p_pol_id        NUMBER
   ,p_contact_id    NUMBER
   ,p_work_group_id NUMBER
  ) RETURN NUMBER;

  /**
  * ��������� �������������� �� ������������� ������� � ������� �����������
  * @author �������
  * @param p_pol_id �� ������
  * @param p_session_id - ����� ������ ��������
  * @return �� ���������������
  */
  FUNCTION load_assured_old
  (
    p_pol_id        NUMBER
   ,p_session_id    NUMBER
   ,p_check_present NUMBER DEFAULT 0
   ,p_out_number    OUT NUMBER
  ) RETURN VARCHAR2;

  FUNCTION load_assured
  (
    p_pol_id     NUMBER
   ,p_session_id NUMBER
   ,p_out_number OUT NUMBER
  ) RETURN VARCHAR2;

  /**
  *�������� ����� ����������� �� ���� �������� �����������
  * @author ��������
  * @param p_pol_id - �� ������ ��������
  * @param p_sum - �����
  */
  PROCEDURE update_asset_sum
  (
    p_pol_id IN NUMBER
   ,p_sum    IN NUMBER
  );

  /**
  * ���������, ��� �������� ������ ��������������
  * @author �������
  * @param p_id - �� ������ ��������
  * @param p_person_id
  */
  PROCEDURE set_user_person_id
  (
    p_id        NUMBER
   ,p_person_id NUMBER
  );
  PROCEDURE set_user_person_id_old
  (
    p_id        NUMBER
   ,p_person_id NUMBER
  );

  /**
  *�������� �� ������� ���. ���-�� �������� �� ������ ��� ������� �������
  * @author ��������
  * @param p_pol_id - �� ������ ��������
  */
  PROCEDURE check_count_cover(par_policy_id NUMBER);
END;
/

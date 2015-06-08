CREATE OR REPLACE PACKAGE pkg_amath AS
  -- @Author Marchuk A.
  -- @Пакет "актуарной математики"
  -- @Реализует основные актуарные вычисления
  --
  /**
  * Возвращает a_n - современную стоимость (PV) финансового / детерминированного аннуитета
  * @author Marchuk A.
  * @param n Срок выплат
  * @param m - число выплат в год (1, 2, 4, 12) По умолчанию m = 1
  * @param IsPrenumerando - 1 аннуитет пренумерандо (выплаты в начале каждого периода. 2- постнумерандо (в конце периода) По умолчанию IsPrenumerando =1
  */

  FUNCTION a_n
  (
    n              IN NUMBER
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает a_x - современную стоимость (PV) пожизненной ренты пренумерадо
  * @author Marchuk A.
  * @param n Срок выплат
  * @param m - число выплат в год (1, 2, 4, 12) По умолчанию m = 1
  * @param IsPrenumerando - 1 аннуитет пренумерандо (выплаты в начале каждого периода. 2- постнумерандо (в конце периода) По умолчанию IsPrenumerando =1
  */

  FUNCTION a_x
  (
    x              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает a_x - современную стоимость (PV) пожизненной ренты пренумерадо
  * @author Marchuk A.
  * @param n Срок выплат
  * @param m - число выплат в год (1, 2, 4, 12) По умолчанию m = 1
  * @param IsPrenumerando - 1 аннуитет пренумерандо (выплаты в начале каждого периода. 2- постнумерандо (в конце периода) По умолчанию IsPrenumerando =1
  */

  FUNCTION a_xy
  (
    x              IN NUMBER
   ,p_sex_x        IN VARCHAR2
   ,y              IN NUMBER
   ,p_sex_y        IN VARCHAR2
   ,m              IN NUMBER
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает n_a_x - отсроченный на n лет пожизненный аннуитет пренуменадо - приведенная на начало действия договора страхования
  * ожидаемая величина пожизненной ренты (пенсии), отсроченной на n лет при условии, что первая выплата производится через n лет
  * после начала действия договора страхования в начале каждого страхового года, если застрахованный к этому времени жив
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION n_a_x
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает s_n - современную стоимость финансового / детерминированного накопления с выплатами в размере "1" в год (при выплатах m раз в год размер каждой выплаты 1/m)
  * @author Marchuk A.
  * @param n Срок выплат
  * @param m - число выплат в год (1, 2, 4, 12) По умолчанию m = 1
  * @param IsPrenumerando - 1 аннуитет пренумерандо (выплаты в начале каждого периода. 2- постнумерандо (в конце периода) По умолчанию IsPrenumerando =1
  */

  FUNCTION s_n
  (
    n              IN NUMBER
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает qx (либо qx "нагруженный" коэффициентами)
  * @author Marchuk A.
  * @param x - возраст
  * @param Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  */
  --
  FUNCTION qx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает px - вероятность для лица возраста х дожить до возраста x+1
  * @author Marchuk A.
  * @param x - возраст
  * @param Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  */
  FUNCTION px
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает pxk вероятность для лица возраста х дожить до возраста x+k
  * @author Marchuk A.
  * @param x - возраст
  * @param k - количество лет
  * @param Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  */

  FUNCTION pxk
  (
    x          IN NUMBER
   ,k          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает qxk (вероятность того что лицо x умрет в течение k лет)
  * @author Marchuk A.
  * @param x - возраст
  * @param k - количество лет
  * @param Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  */

  FUNCTION qxk
  (
    x          IN NUMBER
   ,k          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;

  --
  /**
  * Возвращает величину nEx = p(x,n) * v^n для измененной ("нагруженной") таблицы смертности
  * @author Marchuk A.
  * @param x - возраст
  * @param k - количество лет
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION nex
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;
  --
  /**
  * Возвращает показатель таблицы смертности, характеризующий число лиц, доживших до возраста x
  * @author Marchuk A.
  * @param x - возраст
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  */

  FUNCTION lx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;
  --

  /**
  * Возвращает Dx (коммутационная функция) для измененной ("нагруженной") таблицы смертности
  * @author Marchuk A.
  * @param x - возраст
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION dx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;
  /**
  * Возвращает Nx (коммутационная функция) для измененной ("нагруженной") таблицы смертности
  * @author Marchuk A.
  * @param x - возраст
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION nx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает Cx (коммутационная функция) для измененной ("нагруженной") таблицы смертности
  * @author Marchuk A.
  * @param x - возраст
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION cx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает Mx (коммутационная функция) для измененной ("нагруженной") таблицы смертности
  * @author Marchuk A.
  * @param x - возраст
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION mx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает Rx (коммутационная функция) для измененной ("нагруженной") таблицы смертности
  * @author Marchuk A.
  * @param x - возраст
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION rx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает Sx (коммутационная функция) для измененной ("нагруженной") таблицы смертности
  * @author Marchuk A.
  * @param x - возраст
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION sx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает Ax1n (APV, современную стоимость срочного страхования жизни на n лет) для измененной ("нагруженной") таблицы смертности на "1" страховой суммы
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION ax1n
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  FUNCTION axt1nt_famdep
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,t          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;
  /**
  * Возвращает Axn1 (APV, современную стоимость страхования на дожитие сроком n лет) для измененной ("нагруженной") таблицы смертности на "1" страховой суммы
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION axn1
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает IAx1n  - APV, современную стоимость срочного страхования жизни на n лет с возрастающей страховой суммой (при смерти в течение m-го года, m<=n выплачивается страховая сумма, равная m)
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION iax1n
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает Axn (APV, современную стоимость смешанного страхования жизни на n лет) на "1" страховой суммы
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION axn
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  FUNCTION axtnt_famdep
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,t          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;
  --
  /**
  * Возвращает Ax (APV, современную стоимость пожизненного страхования) на "1" страховой суммы
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */
  FUNCTION ax
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;
  --

  /**
  * Возвращает IAx (APV, современную стоимость возрастающей пожизненной страховки) Страховая сумма равна n в конце n-го года
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION iax
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;
  --
  /**
  * Возвращает a_xn современную стоимость (APV) срочного страхового аннуитета с выплатами n лет Выплаты ежегодные в размере "1"
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION a_xn
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  FUNCTION a_xtnt_famdep
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,t              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
  ) RETURN NUMBER;
  --
  /**
  * Возвращает am_xn_KS - современную стоимость (APV) срочного страхового аннуитета с выплатами n лет в размере "1" в год (при выплатах m раз в год размер каждой выплаты 1/m)
  * При вычислении для выплат m раз в год используется аппроксимация Вулхауса (Woolhouse formula, TFA, Vol 37, p.63)
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION am_xn
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает am_x современную стоимость (APV) пожизненного аннуитета с выплатами n лет
  * в размере "1" в год (при выплатах m раз в год размер каждой выплаты 1/m)
  * При вычислении для выплат m раз в год используется аппроксимация
  * Вулхауса (Woolhouse formula, TFA, Vol 37, p.63)
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION am_x
  (
    x              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  /*
  * Возвращает Axn (APV, современную стоимость смешанного страхования жизни на n лет) на "1" страховой суммы
  * для продукта Семейный Депозит 2014
  * выделена отдельная функция из-за нормы доходности, зависящей от года страхования
  * @author Капля П., Доброхотова И.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */
  FUNCTION axn_famdep2014
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;

  /*
  * Возвращает a_xn современную стоимость (APV) срочного страхового аннуитета с выплатами n лет Выплаты ежегодные в размере "1"
  * для продукта Семейный Депозит 2014
  * выделена отдельная функция из-за нормы доходности, зависящей от года страхования
  * @author Капля П., Доброхотова И.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */
  FUNCTION a_xn_famdep2014
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;

END pkg_amath;
/
CREATE OR REPLACE PACKAGE BODY pkg_amath IS
  --
  --Пакет "актуарной математики"
  --Реализует основные актуарные вычисления

  gc_normrate_famdep_3    CONSTANT NUMBER := 0.05;
  gc_normrate_famdep_else CONSTANT NUMBER := 0.04;

  -- Капля П.
  -- Дикие требования по срокам и несистемный расчет требует вот такую кастыльную реализацию
  -- Простите нас потомки, ничего нельзя делать в спешке...
  gc_normrate_famdep2015_3    CONSTANT NUMBER := 0.1;
  gc_normrate_famdep2015_else CONSTANT NUMBER := 0.04;

  /**
  * Возвращает a_n - современную стоимость (PV) финансового / детерминированного аннуитета
  * @author Marchuk A.
  * @param n Срок выплат
  * @param m - число выплат в год (1, 2, 4, 12) По умолчанию m = 1
  * @param IsPrenumerando - 1 аннуитет пренумерандо (выплаты в начале каждого периода. 2- постнумерандо (в конце периода) По умолчанию IsPrenumerando =1
  */
  FUNCTION a_n
  (
    n              IN NUMBER
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v      NUMBER;
  BEGIN
    v := 1 / (1 + p_i);
    IF p_i = 0
    THEN
      RESULT := n;
    ELSE
      RESULT := 1 / m * (1 - power(v, (n * m - 1) / m)) / (1 - power(v, 1 / m)); --пренумерандо
      IF isprenumerando = 0
      THEN
        RESULT := power(v, 1 / m) * RESULT; --postnumerando
      END IF;
    END IF;
    RETURN RESULT;
  END;

  /**
  * Возвращает a_x - современную стоимость (PV) пожизненной ренты пренумерадо
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности  */

  FUNCTION a_x
  (
    x              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER DEFAULT 0;
    w      NUMBER;
    v      NUMBER;
    v_lx   NUMBER;
  BEGIN
    v := 1 / (1 + p_i);
    --
    SELECT (MAX(age) - (x)) INTO w FROM deathrate_d WHERE deathrate_id = p_table_id;
    --
    v_lx := lx(x, p_sex, k_koeff, s_koeff, p_table_id);
  
    IF isprenumerando = 1
    THEN
      FOR j IN 0 .. w
      LOOP
        RESULT := RESULT + power(v, j) * lx(x + j, p_sex, k_koeff, s_koeff, p_table_id) / v_lx;
      END LOOP;
    ELSE
      RESULT := NULL;
    END IF;
    RETURN RESULT;
  END;

  /**
  * Возвращает a_xy - современную стоимость единичного пожизненного (пренумерандо)
  * аннуитета, выплачиваемого до "первой смерти" для двух человек в возрасте x и y соответственно
  * @author Marchuk A.
  * @param x - возраст основного застрахованного
  * @param p_Sex_x - пол ("m" / "w") основного застрахованного
  * @param y - возраст дополнительного застрахованного
  * @param m - количесво выплат в году
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности  */

  FUNCTION a_xy
  (
    x              IN NUMBER
   ,p_sex_x        IN VARCHAR2
   ,y              IN NUMBER
   ,p_sex_y        IN VARCHAR2
   ,m              IN NUMBER
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v_lx   NUMBER;
    v_ly   NUMBER;
    v_dxy  NUMBER;
    v_nxy  NUMBER;
    v      NUMBER;
    w      NUMBER;
  BEGIN
    v := 1 / (1 + p_i);
    SELECT (MAX(age) - (x)) INTO w FROM deathrate_d WHERE deathrate_id = p_table_id;
    --
    v_lx := lx(x, p_sex_x, k_koeff, s_koeff, p_table_id);
    v_ly := lx(y, p_sex_y, k_koeff, s_koeff, p_table_id);
    --
    v_dxy := power(v, (x + y) / 2) * v_lx * v_ly;
    --
    FOR j IN 0 .. w
    LOOP
      v_lx  := lx(x + j, p_sex_x, k_koeff, s_koeff, p_table_id);
      v_ly  := lx(y + j, p_sex_y, k_koeff, s_koeff, p_table_id);
      v_nxy := v_nxy + power(v, (x + j + y + j) / 2) * v_lx * v_ly;
    END LOOP;
    RESULT := v_nxy / v_dxy - (m - 1) / (2 * m);
    RETURN RESULT;
  END;

  /**
  * Возвращает n_a_x - отсроченный на n лет пожизненный аннуитет пренуменадо - приведенная на начало действия договора страхования
  * ожидаемая величина пожизненной ренты (пенсии), отсроченной на n лет при условии, что первая выплата производится через n лет
  * после начала действия договора страхования в начале каждого страхового года, если застрахованный к этому времени жив
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION n_a_x
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER DEFAULT 0;
    w      NUMBER;
    v      NUMBER;
    v_lx   NUMBER;
  BEGIN
    v := 1 / (1 + p_i);
    --
    SELECT (MAX(age) - (x)) INTO w FROM deathrate_d WHERE deathrate_id = p_table_id;
    --
    v_lx := lx(x, p_sex, k_koeff, s_koeff, p_table_id);
  
    IF isprenumerando = 1
    THEN
      FOR j IN (n) .. w
      LOOP
        RESULT := RESULT + power(v, j) * lx(x + j, p_sex, k_koeff, s_koeff, p_table_id) / v_lx;
      END LOOP;
    ELSE
      RESULT := NULL;
    END IF;
    RETURN RESULT;
  END;

  /**
  * Возвращает s_n - современную стоимость финансового / детерминированного накопления с выплатами в размере "1" в год (при выплатах m раз в год размер каждой выплаты 1/m)
  * @author Marchuk A.
  * @param n Срок выплат
  * @param m - число выплат в год (1, 2, 4, 12) По умолчанию m = 1
  * @param IsPrenumerando - 1 аннуитет пренумерандо (выплаты в начале каждого периода. 2- постнумерандо (в конце периода) По умолчанию IsPrenumerando =1
  */

  FUNCTION s_n
  (
    n              IN NUMBER
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := a_n(n, m, isprenumerando, p_i) * power(1 + p_i, n);
    RETURN RESULT;
  END;

  /**
  * Возвращает qx (либо qx "нагруженный" коэффициентами)
  * @author Marchuk A.
  * @param x - возраст
  * @param Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  */
  --
  FUNCTION qx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := 1 - px(x, p_sex, k_koeff, s_koeff, p_table_id);
    --dbms_output.put_line ('qx = '||result);
    RETURN RESULT;
  END;

  /**
  * Возвращает px - вероятность для лица возраста х дожить до возраста x+1
  * @author Marchuk A.
  * @param x - возраст
  * @param Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  */
  FUNCTION px
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER(16, 8);
  BEGIN
    SELECT (decode(p_sex, 'm', lx_m_next, 'w', lx_f_next)) / decode(p_sex, 'm', lx_m, 'w', lx_f)
      INTO RESULT
      FROM (SELECT age
                  ,decode(p_sex, 'm', lx_m, 'w', lx_f)
                  ,lx_m
                  ,lx_f
                  ,lead(lx_m) over(ORDER BY age) lx_m_next
                  ,lead(lx_f) over(ORDER BY age) lx_f_next
              FROM deathrate_d
             WHERE 1 = 1
               AND deathrate_d.age BETWEEN x AND (x + 1)
               AND deathrate_d.deathrate_id = p_table_id)
     WHERE 1 = 1
       AND age = x;
    --dbms_output.put_line ('px(без нагр. коэф.) = '||result);
    RESULT := 1 - ((1 + k_koeff) * (1 - RESULT) + s_koeff);
    --dbms_output.put_line ('px = '||result);
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000, 'No data found AMath.px () for age = ' || x);
    
  END px;

  /**
  * Возвращает qxk (вероятность того что лицо x умрет в течение k лет)
  * @author Marchuk A.
  * @param x - возраст
  * @param k - количество лет
  * @param Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  */
  FUNCTION qxk
  (
    x          IN NUMBER
   ,k          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    IF k = 0
       OR k IS NULL
    THEN
      RESULT := 0;
    ELSE
      SELECT (decode(p_sex, 'm', lx_m, 'w', lx_f) -
             decode(p_sex, 'm', nvl(lx_m_next, 0), 'w', nvl(lx_f_next, 0))) /
             decode(p_sex, 'm', lx_m, 'w', lx_f)
        INTO RESULT
        FROM (SELECT age
                    ,decode(p_sex, 'm', lx_m, 'w', lx_f)
                    ,lx_m
                    ,lx_f
                    ,lead(lx_m) over(ORDER BY age) lx_m_next
                    ,lead(lx_f) over(ORDER BY age) lx_f_next
                FROM deathrate_d
               WHERE age IN (x, x + k)
                 AND deathrate_id = p_table_id)
       WHERE 1 = 1
         AND age = x;
    END IF;
    --dbms_output.put_line ('qxk = '||result);
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000, 'AMath.qxk(): x is out of life table range');
    WHEN OTHERS THEN
      RAISE;
    
  END;

  /**
  * Возвращает величину nEx = p(x,n) * v^n для измененной ("нагруженной") таблицы смертности
  * @author Marchuk A.
  * @param x - возраст
  * @param k - количество лет
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */
  FUNCTION nex
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v      NUMBER;
  BEGIN
    v      := 1 / (1 + p_i);
    RESULT := pxk(x, n, p_sex, k_koeff, s_koeff, p_table_id) * power(v, n);
    RETURN RESULT;
  END;

  /**
  * Возвращает pxk вероятность для лица возраста х дожить до возраста x+k
  * @author Marchuk A.
  * @param x - возраст
  * @param k - количество лет
  * @param Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  */

  FUNCTION pxk
  (
    x          IN NUMBER
   ,k          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
  BEGIN
    p_xk := 1; --значение p(x, 0)
    FOR j IN 0 .. (k - 1)
    LOOP
      --значение p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
    RESULT := p_xk;
    --dbms_output.put_line ('pxk = '||result);
    RETURN RESULT;
  END;

  /**
  * Возвращает qxk (вероятность того что лицо x умрет в течение k лет)
  * @author Marchuk A.
  * @param x - возраст
  * @param k - количество лет
  * @param Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  */

  FUNCTION qxk
  (
    x          IN NUMBER
   ,k          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := 1 - pxk(x, k, p_sex, k_koeff, s_koeff, p_table_id);
    --dbms_output.put_line ('qxk = '||result);
    RETURN RESULT;
  END;

  /**
  * Возвращает показатель таблицы смертности, характеризующий число лиц, доживших до возраста x
  * @author Marchuk A.
  * @param x - возраст
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  */

  FUNCTION lx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    minage NUMBER;
    RESULT NUMBER;
    l_pxk  NUMBER;
  BEGIN
    --
    SELECT decode(p_sex, 'm', lx_m, 'w', lx_f) lx
      INTO RESULT
      FROM deathrate_d
     WHERE 1 = 1
       AND age = x
       AND deathrate_d.deathrate_id = p_table_id;
    --
    IF NOT (k_koeff = 0 AND s_koeff = 0)
    THEN
      SELECT MIN(age) INTO minage FROM deathrate_d WHERE deathrate_id = p_table_id;
    
      SELECT decode(p_sex, 'm', lx_m, 'w', lx_f) lx
        INTO RESULT
        FROM deathrate_d
       WHERE 1 = 1
         AND age = minage
         AND deathrate_d.deathrate_id = p_table_id;
    
      FOR i IN (minage + 1) .. x
      LOOP
        l_pxk  := pxk(i - 1, 1, p_sex, k_koeff, s_koeff, p_table_id);
        RESULT := RESULT * l_pxk;
      END LOOP;
    END IF;
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000, 'AMath.Lx(): x is out of life table range ' || x);
    WHEN OTHERS THEN
      RAISE;
  END;

  /**
  * Возвращает Dx (коммутационная функция) для измененной ("нагруженной") таблицы смертности
  * @author Marchuk A.
  * @param x - возраст
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION dx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v      NUMBER;
  BEGIN
    v      := 1 / (1 + p_i);
    RESULT := power(v, x) * lx(x, p_sex, k_koeff, s_koeff, p_table_id);
    RETURN RESULT;
  END;

  /**
  * Возвращает Nx (коммутационная функция) для измененной ("нагруженной") таблицы смертности
  * @author Marchuk A.
  * @param x - возраст
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION nx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    n      NUMBER;
    j      NUMBER;
  BEGIN
    --n = aTable.MaximumAge - x --срок до последнего возраста в таблице смертности
    SELECT (MAX(age) - x) INTO n FROM deathrate_d WHERE deathrate_id = p_table_id;
    RESULT := 0;
    FOR j IN 0 .. n
    LOOP
      RESULT := RESULT + dx(x + j, p_sex, k_koeff, s_koeff, p_table_id, p_i);
    END LOOP;
    RETURN RESULT;
  END;

  /**
  * Возвращает Cx (коммутационная функция) для измененной ("нагруженной") таблицы смертности
  * @author Marchuk A.
  * @param x - возраст
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION cx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v_dx   NUMBER;
    v      NUMBER;
  BEGIN
    --dx = lx * qx
    v      := 1 / (1 + p_i);
    v_dx   := lx(x, p_sex, k_koeff, s_koeff, p_table_id) * qx(x, p_sex, k_koeff, s_koeff, p_table_id);
    RESULT := power(v, (x + 1)) * v_dx;
    RETURN RESULT;
  END;

  /**
  * Возвращает Mx (коммутационная функция) для измененной ("нагруженной") таблицы смертности
  * @author Marchuk A.
  * @param x - возраст
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION mx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER
   ,s_koeff    IN NUMBER
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    n      NUMBER;
    j      NUMBER;
  BEGIN
    -- n = aTable.MaximumAge - x --срок до последнего возраста в таблице смертности
    SELECT (MAX(age) - x) INTO n FROM deathrate_d WHERE deathrate_id = p_table_id;
    RESULT := 0;
    FOR j IN 0 .. n - 1
    LOOP
      --Cx определена до возраста (MaximumAge - 1)
      RESULT := RESULT + cx(x + j, p_sex, k_koeff, s_koeff, p_table_id, p_i);
    END LOOP;
    RETURN RESULT;
  END;

  --Возвращает Rx (коммутационная функция) для измененной ("нагруженной") таблицы смертности
  --См. комментарии к qxk_KS(...)
  --ВНИМАНИЕ:  в расчетах лучше использовать рекуррентное соотношение
  --т.к. эта функция пересчитывает все промежуточные qx
  --
  --x - возраст
  --Sex - пол ("m" / "w")
  --K_koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  --S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  FUNCTION rx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    n      NUMBER;
    j      NUMBER;
  BEGIN
    --n = aTable.MaximumAge - x --срок до последнего возраста в таблице смертности
    SELECT (MAX(age) - x) INTO n FROM deathrate_d WHERE deathrate_id = p_table_id;
    RESULT := 0;
    -- Cx определена до возраста (MaximumAge - 1)
    FOR j IN 0 .. (n - 1)
    LOOP
      RESULT := RESULT + (j + 1) * cx(x + j, p_sex, k_koeff, s_koeff, p_table_id, p_i);
    END LOOP;
    RETURN RESULT;
  END;

  /**
  * Возвращает Sx (коммутационная функция) для измененной ("нагруженной") таблицы смертности
  * @author Marchuk A.
  * @param x - возраст
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION sx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    n      NUMBER;
    j      NUMBER;
  BEGIN
    --n = aTable.MaximumAge - x --срок до последнего возраста в таблице смертности
    SELECT (MAX(age) - x) INTO n FROM deathrate_d WHERE deathrate_id = p_table_id;
    RESULT := 0;
    --  --Dx определена до возраста (MaximumAge)
    FOR j IN 0 .. n
    LOOP
      RESULT := RESULT + (j + 1) * dx(x + j, p_sex, k_koeff, s_koeff, p_table_id, p_i);
    END LOOP;
    RETURN RESULT;
  END;

  /**
  * Возвращает Ax1n (APV, современную стоимость срочного страхования жизни на n лет) для измененной ("нагруженной") таблицы смертности на "1" страховой суммы
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION ax1n
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
    v      NUMBER;
  BEGIN
    v      := 1 / (1 + p_i);
    RESULT := 0;
    p_xk   := 1; --значение p(x, 0)
    FOR j IN 0 .. (n - 1)
    LOOP
      RESULT := RESULT + p_xk * qx(x + j, p_sex, k_koeff, s_koeff, p_table_id) * power(v, (j + 1));
      --  значение p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
  
    RETURN RESULT;
  END;

  FUNCTION axt1nt_famdep
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,t          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
    v      NUMBER;
    v_j    NUMBER; -- накопленная норма доходности за несколько лет
  BEGIN
    --v := 1 / (1 + p_i);
    RESULT := 0;
    p_xk   := 1; --значение p(x, 0)
    v_j    := 1;
    FOR j IN 0 .. (n - t - 1)
    LOOP
      IF (t + j) < 3
      THEN
        v   := 1 / (1 + gc_normrate_famdep_3);
        v_j := v_j * v; --* норма доходности за j лет
      ELSE
        v   := 1 / (1 + gc_normrate_famdep_else);
        v_j := v_j * v; --* норма доходности за j лет
      END IF;
      --*    Result := Result + p_xk * qx (x + j, p_Sex, K_koeff, S_koeff, p_table_id) * power (v , (j + 1));
      RESULT := RESULT + p_xk * qx(x + t + j, p_sex, k_koeff, s_koeff, p_table_id) * v_j;
    
      --  значение p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + t + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
  
    RETURN RESULT;
  END axt1nt_famdep;

  /**
  * Возвращает Axn1 (APV, современную стоимость страхования на дожитие сроком n лет) для измененной ("нагруженной") таблицы смертности на "1" страховой суммы
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION axn1
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v      NUMBER;
  BEGIN
    v      := 1 / (1 + p_i);
    RESULT := pxk(x, n, p_sex, k_koeff, s_koeff, p_table_id) * power(v, n);
    RETURN RESULT;
  END;

  /**
  * Возвращает IAx1n  - APV, современную стоимость срочного страхования жизни на n лет с возрастающей страховой суммой (при смерти в течение m-го года, m<=n выплачивается страховая сумма, равная m)
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION iax1n
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
    v      NUMBER;
  BEGIN
    --значение p(x, 0)
    v      := 1 / (1 + p_i);
    p_xk   := 1;
    RESULT := 0;
    FOR j IN 0 .. (n - 1)
    LOOP
      RESULT := RESULT +
                (j + 1) * p_xk * qx(x + j, p_sex, k_koeff, s_koeff, p_table_id) * power(v, (j + 1));
      --значение p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
    RETURN RESULT;
  END;

  /**
  * Возвращает Axn (APV, современную стоимость смешанного страхования жизни на n лет) на "1" страховой суммы
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION axn
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
    v      NUMBER;
  BEGIN
    --dbms_output.put_line (' x='||x||' n='||n||' p_sex= '||p_Sex||' p_table_id='||p_table_id);
    v      := 1 / (1 + p_i);
    RESULT := 0;
    --значение p(x, 0)
    p_xk := 1;
    FOR j IN 0 .. (n - 1)
    LOOP
      RESULT := RESULT + p_xk * qx(x + j, p_sex, k_koeff, s_koeff, p_table_id) * power(v, (j + 1));
      -- значение p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
    -- now Result = Ax1n
    -- Set Axn = Ax1n + v^n* p(x, n)
    RESULT := RESULT + power(v, n) * p_xk;
    RETURN RESULT;
  END;

  FUNCTION axtnt_famdep
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,t          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
    v      NUMBER;
    v_j    NUMBER; -- накопленная норма доходности за несколько лет
  BEGIN
    --dbms_output.put_line (' x='||x||' n='||n||' p_sex= '||p_Sex||' p_table_id='||p_table_id);
    --v := 1 / (1 + p_i);
    RESULT := 0;
    --значение p(x, 0)
    p_xk := 1;
    v_j  := 1;
    FOR j IN 0 .. (n - t - 1)
    LOOP
      IF (t + j) < 3
      THEN
        v   := 1 / (1 + gc_normrate_famdep_3);
        v_j := v_j * v; --* норма доходности за j лет
      ELSE
        v   := 1 / (1 + gc_normrate_famdep_else);
        v_j := v_j * v; --* норма доходности за j лет
      END IF;
      --*    Result := Result + p_xk * qx (x + j, p_sex, K_koeff, S_koeff, p_table_id) * power (v , (j + 1));
      RESULT := RESULT + p_xk * qx(x + t + j, p_sex, k_koeff, s_koeff, p_table_id) * v_j;
      -- значение p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + t + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
    -- now Result = Ax1n
    -- Set Axn = Ax1n + v^n* p(x, n)
    --*  result := Result + power (v , n) * p_xk;
    RESULT := RESULT + v_j * p_xk;
    RETURN RESULT;
  END;

  /**
  * Возвращает Ax (APV, современную стоимость пожизненного страхования) на "1" страховой суммы
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION ax
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    n      NUMBER;
    j      NUMBER;
  BEGIN
    --n = aTable.MaximumAge -  --срок страхования - до последнего возраста в таблице смертности
    SELECT (MAX(age) - x) INTO n FROM deathrate_d WHERE deathrate_id = p_table_id;
    RESULT := 0;
    --------------------------
    --For j = 0 To n - 1
    --   Result = Result + pxk(x, j, Sex) * qx(x + j, Sex) * v ^ (j + 1)
    --Next j
    --------------------------
    RESULT := axn(x, n, p_sex, k_koeff, s_koeff, p_table_id, p_i);
    ---------------------------
    RETURN RESULT;
  END;

  /**
  * Возвращает IAx (APV, современную стоимость возрастающей пожизненной страховки) Страховая сумма равна n в конце n-го года
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION iax
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    n      NUMBER;
    j      NUMBER;
    p_xk   NUMBER;
    v      NUMBER;
  BEGIN
    v := 1 / (1 + p_i);
    --
    SELECT (MAX(age) - x) INTO n FROM deathrate_d WHERE deathrate_id = p_table_id;
    -- n = aTable.MaximumAge - x --срок страхования - до последнего возраста в таблице смертности
    -- --значение p(x, 0)
    p_xk   := 1;
    RESULT := 0;
    FOR j IN 0 .. n - 1
    LOOP
      RESULT := RESULT +
                (j + 1) * p_xk * qx(x + j, p_sex, k_koeff, s_koeff, p_table_id) * power(v, (j + 1));
      -- --значение p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
    RETURN RESULT;
  END;

  /**
  * Возвращает a_xn современную стоимость (APV) срочного страхового аннуитета с выплатами n лет Выплаты ежегодные в размере "1"
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION a_xn
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
    v      NUMBER;
  BEGIN
    v      := 1 / (1 + p_i);
    RESULT := 0;
    p_xk   := 1; --значение p(x, 0)
    IF isprenumerando = 1
    THEN
      FOR j IN 0 .. (n - 1)
      LOOP
        RESULT := RESULT + p_xk * power(v, j);
        -- --значение p(x, k + 1) = p(x, k) * p(x + k, 1)
        p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
        --     dbms_output.put_line ('Result='||Result||'j= '||j||' p_xk '||p_xk);
      END LOOP;
    ELSIF isprenumerando = 0
    THEN
      FOR j IN 1 .. n
      LOOP
        -- --значение p(x, k + 1) = p(x, k) * p(x + k, 1)
        p_xk   := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
        RESULT := RESULT + p_xk * power(v, j);
      END LOOP;
    END IF;
    --dbms_output.put_line ('a_xn = '||Result);
    RETURN RESULT;
  END;

  FUNCTION a_xtnt_famdep
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,t              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
    v      NUMBER;
    v_j    NUMBER; -- накопленная норма доходности за несколько лет
    temp1  NUMBER;
    temp2  NUMBER;
  BEGIN
    --  v := 1 / (1 + p_i);
    RESULT := 0;
    p_xk   := 1; --значение p(x, 0)
    v_j    := 1;
    IF isprenumerando = 1
    THEN
      FOR j IN 0 .. (n - t - 1)
      LOOP
        temp1 := power(v, j);
        temp2 := p_xk * v_j;
        --*      Result := Result + p_xk * power (v , j);
        RESULT := RESULT + p_xk * v_j;
        -- --значение p(x, k + 1) = p(x, k) * p(x + k, 1)
        p_xk := p_xk * px(x + t + j, p_sex, k_koeff, s_koeff, p_table_id);
        --     dbms_output.put_line ('Result='||Result||'j= '||j||' p_xk '||p_xk);
        IF (t + j) < 3
        THEN
          v   := 1 / (1 + gc_normrate_famdep_3);
          v_j := v_j * v; --* норма доходности за j лет
        ELSE
          v   := 1 / (1 + gc_normrate_famdep_else);
          v_j := v_j * v; --* норма доходности за j лет
        END IF;
      END LOOP;
    ELSIF isprenumerando = 0
    THEN
      FOR j IN 1 .. (n - t)
      LOOP
        IF (t + j) <= 3
        THEN
          v   := 1 / (1 + gc_normrate_famdep_3);
          v_j := v_j * v; --* норма доходности за j лет
        ELSE
          v   := 1 / (1 + gc_normrate_famdep_else);
          v_j := v_j * v; --* норма доходности за j лет
        END IF;
        -- --значение p(x, k + 1) = p(x, k) * p(x + k, 1)
        p_xk := p_xk * px(x + t + j, p_sex, k_koeff, s_koeff, p_table_id);
        --*      Result := Result + p_xk * power (v , j);
        RESULT := RESULT + p_xk * v_j;
      END LOOP;
    END IF;
    --dbms_output.put_line ('a_xn = '||Result);
    RETURN RESULT;
  END;

  /**
  * Возвращает am_xn - современную стоимость (APV) срочного страхового аннуитета с выплатами n лет в размере "1" в год (при выплатах m раз в год размер каждой выплаты 1/m)
  * При вычислении для выплат m раз в год используется аппроксимация Вулхауса (Woolhouse formula, TFA, Vol 37, p.63)
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION am_xn
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v      NUMBER;
  BEGIN
    v := 1 / (1 + p_i);
    IF isprenumerando = 1
    THEN
      RESULT := a_xn(x, n, p_sex, k_koeff, s_koeff, 1, p_table_id, p_i) -
                (m - 1) / (2 * m) * (1 - pxk(x, n, p_sex, k_koeff, s_koeff, p_table_id) * power(v, n));
    ELSE
      RESULT := a_xn(x, n, p_sex, k_koeff, s_koeff, 0, p_table_id, p_i) +
                (m - 1) / (2 * m) * (1 - pxk(x, n, p_sex, k_koeff, s_koeff, p_table_id) * power(v, n));
    END IF;
    RETURN RESULT;
  END;

  /**
  * Возвращает am_x современную стоимость (APV) пожизненного аннуитета с выплатами n лет
  * в размере "1" в год (при выплатах m раз в год размер каждой выплаты 1/m)
  * При вычислении для выплат m раз в год используется аппроксимация
  * Вулхауса (Woolhouse formula, TFA, Vol 37, p.63)
  * @author Marchuk A.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION am_x
  (
    x              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    n      NUMBER;
    j      NUMBER;
  BEGIN
    --  n = aTable.MaximumAge - x --срок  - до последнего возраста в таблице смертности
    SELECT (MAX(age) - (x + 1)) INTO n FROM deathrate_d WHERE deathrate_id = p_table_id;
    --пожизненный аннуитет постнумерандо, выплаты ежегодно
    RESULT := a_xn(x, n, p_sex, k_koeff, s_koeff, isprenumerando, p_table_id, p_i);
    IF isprenumerando = 1
    THEN
      RESULT := RESULT + (m + 1) / (2 * m);
    ELSE
      RESULT := RESULT + (m - 1) / (2 * m);
    END IF;
    RETURN RESULT;
  END;

  /*
  * Возвращает Axn (APV, современную стоимость смешанного страхования жизни на n лет) на "1" страховой суммы
  * для продукта Семейный Депозит 2014
  * выделена отдельная функция из-за нормы доходности, зависящей от года страхования
  * @author Капля П., Доброхотова И.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */
  FUNCTION axn_famdep2014
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT     NUMBER;
    p_xk       NUMBER;
    j          NUMBER;
    v_normrate NUMBER;
    v          NUMBER; -- производная от нормы доходности на текущий год 1/(1+ normrate)
    d_1        NUMBER; --В файле  величина 1/D
    vj         NUMBER := 1; -- камулятивное произведение v
  BEGIN
    --dbms_output.put_line (' x='||x||' n='||n||' p_sex= '||p_Sex||' p_table_id='||p_table_id);
    --  v := 1 / (1 + p_i);
    RESULT := 0;
    --значение p(x, 0)
    p_xk := 1;
    FOR j IN 0 .. (n - 1)
    LOOP
      IF j < 3
      THEN
        v_normrate := gc_normrate_famdep2015_3;
      
      ELSE
        v_normrate := gc_normrate_famdep2015_else;
      END IF;
      v      := 1 / (1 + v_normrate);
      d_1    := v_normrate / ln(1 + v_normrate);
      vj     := vj * v;
      RESULT := RESULT + p_xk * qx(x + j, p_sex, k_koeff, s_koeff, p_table_id) * vj * d_1;
      -- значение p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
    -- now Result = Ax1n
    -- Set Axn = Ax1n + v^n* p(x, n)
    RESULT := RESULT + vj * p_xk;
    RETURN RESULT;
  END axn_famdep2014;

  /*
  * Возвращает a_xn современную стоимость (APV) срочного страхового аннуитета с выплатами n лет Выплаты ежегодные в размере "1"
  * для продукта Семейный Депозит 2014
  * выделена отдельная функция из-за нормы доходности, зависящей от года страхования
  * @author Капля П., Доброхотова И.
  * @param x - возраст
  * @param n - срок страхования
  * @param p_Sex - пол ("m" / "w")
  * @param _koeff - коэфф в долях единицы, т.е., например, для 50% K_koeff = 0.50
  * @param S_koeff - коэфф в долях единицы, т.е., например, для 1 промилле S_koeff = 0.001
  * @param p_table_id - ИД используемой таблицы смертности из справочника стат. таблиц
  * @param p_i- техническая норма доходности
  */

  FUNCTION a_xn_famdep2014
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT     NUMBER;
    p_xk       NUMBER;
    j          NUMBER;
    vj         NUMBER := 1;
    v_normrate NUMBER;
  BEGIN
    RESULT := 0;
    p_xk   := 1; --значение p(x, 0)
  
    FOR j IN 0 .. (n - 1)
    LOOP
      IF j < 3
      THEN
        v_normrate := gc_normrate_famdep2015_3;
      ELSE
        v_normrate := gc_normrate_famdep2015_else;
      END IF;
    
      RESULT := RESULT + p_xk * vj;
      vj     := vj / (1 + v_normrate);
      -- --значение p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
      --     dbms_output.put_line ('Result='||Result||'j= '||j||' p_xk '||p_xk);
    END LOOP;
  
    --dbms_output.put_line ('a_xn = '||Result);
    RETURN RESULT;
  END a_xn_famdep2014;

END;
/

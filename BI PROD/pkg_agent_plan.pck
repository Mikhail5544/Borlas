CREATE OR REPLACE PACKAGE pkg_agent_plan IS
  FUNCTION GetManager1Cat(p_month NUMBER) RETURN NUMBER;
  FUNCTION GetManager1CatPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER;

  FUNCTION GetManager2Cat(p_month NUMBER) RETURN NUMBER;
  FUNCTION GetManager2CatPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER;

  FUNCTION GetManagerRProd(p_month NUMBER) RETURN NUMBER;
  FUNCTION GetManagerRProdPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER;

  FUNCTION GetDir1Cat(p_month NUMBER) RETURN NUMBER;
  FUNCTION GetDir1CatPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER;

  FUNCTION GetDir2CatA(p_month NUMBER) RETURN NUMBER;
  FUNCTION GetDir2CatAPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER;

  FUNCTION GetDir2CatB(p_month NUMBER) RETURN NUMBER;
  FUNCTION GetDir2CatBPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER;

  FUNCTION GetDir2CatV(p_month NUMBER) RETURN NUMBER;
  FUNCTION GetDir2CatVPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER;

  FUNCTION GetDir2CatG(p_month NUMBER) RETURN NUMBER;
  FUNCTION GetDir2CatGPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER;

  FUNCTION GetDirTer(p_month NUMBER) RETURN NUMBER;
  FUNCTION GetDirTerPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER;

  FUNCTION GetDirRegA(p_month NUMBER) RETURN NUMBER;
  FUNCTION GetDirRegAPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER;

  FUNCTION GetDirRegB(p_month NUMBER) RETURN NUMBER;
  FUNCTION GetDirRegBPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER;

  FUNCTION GetDirRegV(p_month NUMBER) RETURN NUMBER;
  FUNCTION GetDirRegVPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER;

END pkg_agent_plan;
/
CREATE OR REPLACE PACKAGE BODY pkg_agent_plan IS

  FUNCTION GetManager1Cat(p_month NUMBER) RETURN NUMBER IS
  BEGIN
  
    IF (p_month = 1)
    THEN
      RETURN 90000;
    END IF;
    IF (p_month = 2)
    THEN
      RETURN 90000;
    END IF;
    IF (p_month = 3)
    THEN
      RETURN 110000;
    END IF;
    IF (p_month = 4)
    THEN
      RETURN 130000;
    END IF;
    IF (p_month = 5)
    THEN
      RETURN 150000;
    END IF;
    IF (p_month = 6)
    THEN
      RETURN 170000;
    END IF;
    IF (p_month = 7)
    THEN
      RETURN 190000;
    END IF;
    IF (p_month = 8)
    THEN
      RETURN 210000;
    END IF;
    IF (p_month = 9)
    THEN
      RETURN 230000;
    END IF;
    IF (p_month >= 10)
    THEN
      RETURN 250000;
    END IF;
  
    RETURN 0;
  END GetManager1Cat;

  FUNCTION GetManager1CatPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER IS
  BEGIN
  
    IF (p_percent >= 50 AND p_percent <= 99)
    THEN
      IF (p_month = 1)
      THEN
        RETURN 10000;
      END IF;
      IF (p_month = 2)
      THEN
        RETURN 10000;
      END IF;
      IF (p_month = 3)
      THEN
        RETURN 10000;
      END IF;
      IF (p_month = 4)
      THEN
        RETURN 10000;
      END IF;
      IF (p_month = 5)
      THEN
        RETURN 10000;
      END IF;
      IF (p_month = 6)
      THEN
        RETURN 10000;
      END IF;
      IF (p_month = 7)
      THEN
        RETURN 10000;
      END IF;
      IF (p_month = 8)
      THEN
        RETURN 10000;
      END IF;
      IF (p_month = 9)
      THEN
        RETURN 10000;
      END IF;
      IF (p_month >= 10)
      THEN
        RETURN 10000;
      END IF;
    END IF;
  
    IF (p_percent >= 100)
    THEN
      IF (p_month = 1)
      THEN
        RETURN 15000;
      END IF;
      IF (p_month = 2)
      THEN
        RETURN 15000;
      END IF;
      IF (p_month = 3)
      THEN
        RETURN 15000;
      END IF;
      IF (p_month = 4)
      THEN
        RETURN 15000;
      END IF;
      IF (p_month = 5)
      THEN
        RETURN 15000;
      END IF;
      IF (p_month = 6)
      THEN
        RETURN 15000;
      END IF;
      IF (p_month = 7)
      THEN
        RETURN 15000;
      END IF;
      IF (p_month = 8)
      THEN
        RETURN 15000;
      END IF;
      IF (p_month = 9)
      THEN
        RETURN 15000;
      END IF;
      IF (p_month >= 10)
      THEN
        RETURN 15000;
      END IF;
    END IF;
  
    RETURN 0;
  
  END GetManager1CatPremia;

  FUNCTION GetManager2Cat(p_month NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 250000;
  END GetManager2Cat;

  FUNCTION GetManager2CatPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER IS
  BEGIN
    IF (p_percent >= 100)
    THEN
      RETURN 15000;
    END IF;
    RETURN 0;
  END GetManager2CatPremia;

  FUNCTION GetManagerRProd(p_month NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 500000;
  END GetManagerRProd;

  FUNCTION GetManagerRProdPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER IS
  BEGIN
    IF (p_percent >= 100)
    THEN
      RETURN 25000;
    END IF;
    RETURN 0;
  END GetManagerRProdPremia;

  FUNCTION GetDir1Cat(p_month NUMBER) RETURN NUMBER IS
  BEGIN
  
    IF (p_month = 1)
    THEN
      RETURN 300000;
    END IF;
    IF (p_month = 2)
    THEN
      RETURN 350000;
    END IF;
    IF (p_month = 3)
    THEN
      RETURN 400000;
    END IF;
    IF (p_month = 4)
    THEN
      RETURN 450000;
    END IF;
    IF (p_month = 5)
    THEN
      RETURN 500000;
    END IF;
    IF (p_month = 6)
    THEN
      RETURN 550000;
    END IF;
    IF (p_month = 7)
    THEN
      RETURN 600000;
    END IF;
    IF (p_month = 8)
    THEN
      RETURN 650000;
    END IF;
    IF (p_month = 9)
    THEN
      RETURN 700000;
    END IF;
    IF (p_month = 10)
    THEN
      RETURN 750000;
    END IF;
    IF (p_month = 11)
    THEN
      RETURN 800000;
    END IF;
    IF (p_month = 12)
    THEN
      RETURN 900000;
    END IF;
  
    RETURN 0;
  END GetDir1Cat;

  FUNCTION GetDir1CatPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER IS
  BEGIN
  
    IF (p_percent = 100)
    THEN
      RETURN 25000;
    END IF;
  
    RETURN 0;
  END GetDir1CatPremia;

  FUNCTION GetDir2CatA(p_month NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 1000000;
  END GetDir2CatA;

  FUNCTION GetDir2CatAPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER IS
    maxn NUMBER := 1299999;
  BEGIN
  
    IF (p_percent >= 100 AND p_percent <= (100 * (maxn - GetDir2CatA(p_month)) / GetDir2CatA(p_month)))
    THEN
      RETURN 40000;
    END IF;
  
    RETURN 0;
  END GetDir2CatAPremia;

  FUNCTION GetDir2CatB(p_month NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 1300000;
  END GetDir2CatB;

  FUNCTION GetDir2CatBPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER IS
    maxn NUMBER := 1599999;
  BEGIN
  
    IF (p_percent >= 100 AND p_percent <= (100 * (maxn - GetDir2CatB(p_month)) / GetDir2CatB(p_month)))
    THEN
      RETURN 50000;
    END IF;
  
    RETURN 0;
  END GetDir2CatBPremia;

  FUNCTION GetDir2CatV(p_month NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 1600000;
  END GetDir2CatV;

  FUNCTION GetDir2CatVPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER IS
    maxn NUMBER := 1999999;
  BEGIN
  
    IF (p_percent >= 100 AND p_percent <= (100 * (maxn - GetDir2CatV(p_month)) / GetDir2CatV(p_month)))
    THEN
      RETURN 60000;
    END IF;
  
    RETURN 0;
  END GetDir2CatVPremia;

  FUNCTION GetDir2CatG(p_month NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 2000000;
  END GetDir2CatG;

  FUNCTION GetDir2CatGPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER IS
  BEGIN
    IF (p_percent >= 100)
    THEN
      RETURN 70000;
    END IF;
  
    RETURN 0;
  END GetDir2CatGPremia;

  FUNCTION GetDirTer(p_month NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 3000000;
  END GetDirTer;

  FUNCTION GetDirTerPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER IS
  BEGIN
    IF (p_percent >= 100)
    THEN
      RETURN 80000;
    END IF;
  
    RETURN 0;
  END GetDirTerPremia;

  FUNCTION GetDirRegA(p_month NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 3000000;
  END GetDirRegA;

  FUNCTION GetDirRegAPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER IS
  BEGIN
    IF (p_percent < 0)
    THEN
      RETURN 50000;
    END IF;
  END GetDirRegAPremia;

  FUNCTION GetDirRegB(p_month NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 3000000;
  END GetDirRegB;

  FUNCTION GetDirRegBPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER IS
    maxn NUMBER := 10000000;
  BEGIN
  
    IF (p_percent >= 100 AND p_percent <= (100 * (maxn - GetDirRegB(p_month)) / GetDirRegB(p_month)))
    THEN
      RETURN 75000;
    END IF;
    RETURN 0;
  END GetDirRegBPremia;

  FUNCTION GetDirRegV(p_month NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 10000000;
  END GetDirRegV;

  FUNCTION GetDirRegVPremia
  (
    p_month   NUMBER
   ,p_percent NUMBER
  ) RETURN NUMBER IS
  BEGIN
    IF (p_percent > 100)
    THEN
      RETURN 100000;
    END IF;
    RETURN 0;
  END GetDirRegVPremia;

END pkg_agent_plan;
/

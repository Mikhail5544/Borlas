CREATE OR REPLACE PACKAGE WEBUTIL_DB AUTHID CURRENT_USER AS

  /*********************************************************************************\
   * WebUtil_DB - Database functions used by the WebUtil_File_Transfer
   * Package.  These functions allow reading and writing direct
   * to the specified BLOB in the database.
   *  The functions should not be called externally from WebUtil
   *********************************************************************************
   * Version 1.0.0
   *********************************************************************************
   * Change History
   *   DRMILLS 11/JAN/2003 - Creation
   *
  \*********************************************************************************/

  FUNCTION OpenBlob
  (
    blobTable  IN VARCHAR2
   ,blobColumn IN VARCHAR2
   ,blobWhere  IN VARCHAR2
   ,openMode   IN VARCHAR2
   ,chunkSize  IN PLS_INTEGER DEFAULT NULL
  ) RETURN BOOLEAN;

  FUNCTION CloseBlob(checksum IN PLS_INTEGER) RETURN BOOLEAN;

  PROCEDURE WriteData(data IN VARCHAR2);

  FUNCTION ReadData RETURN VARCHAR;

  FUNCTION GetLastError RETURN PLS_INTEGER;

  FUNCTION GetSourceLength RETURN PLS_INTEGER;

  FUNCTION GetSourceChunks RETURN PLS_INTEGER;

END WEBUTIL_DB;
/
CREATE OR REPLACE PACKAGE BODY WEBUTIL_DB AS
  m_binaryData   BLOB;
  m_blobTable    VARCHAR2(60);
  m_blobColumn   VARCHAR2(60);
  m_blobWhere    VARCHAR2(1024);
  m_mode         CHAR(1);
  m_lastError    PLS_INTEGER := 0;
  m_sourceLength PLS_INTEGER := 0;
  m_bytesRead    PLS_INTEGER := 0;
  MAX_READ_BYTES PLS_INTEGER := 4096;

  -- internal Program Units
  PROCEDURE Reset;

  PROCEDURE Reset IS
  BEGIN
    m_blobTable    := NULL;
    m_blobColumn   := NULL;
    m_blobWhere    := NULL;
    m_mode         := NULL;
    m_lastError    := 0;
    m_sourceLength := 0;
    m_bytesRead    := 0;
  END Reset;

  FUNCTION OpenBlob
  (
    blobTable  IN VARCHAR2
   ,blobColumn IN VARCHAR2
   ,blobWhere  IN VARCHAR2
   ,openMode   IN VARCHAR2
   ,chunkSize  PLS_INTEGER DEFAULT NULL
  ) RETURN BOOLEAN IS
    RESULT    BOOLEAN := FALSE;
    stmtFetch VARCHAR2(2000);
    hit       PLS_INTEGER;
  BEGIN
    -- New transaction clean up
    reset;
  
    m_blobTable  := blobTable;
    m_blobColumn := blobColumn;
    m_blobWhere  := blobWhere;
    m_mode       := upper(openMode);
  
    IF chunkSize IS NOT NULL
    THEN
      IF chunkSize > 16384
      THEN
        MAX_READ_BYTES := 16384;
      ELSE
        MAX_READ_BYTES := chunkSize;
      END IF;
    END IF;
  
    -- check the target row exists
    stmtFetch := 'select count(*) from ' || m_blobTable || ' where ' || m_blobWhere;
    EXECUTE IMMEDIATE stmtFetch
      INTO hit;
  
    IF hit = 1
    THEN
      IF m_mode = 'W'
      THEN
        DBMS_LOB.CREATETEMPORARY(m_binaryData, FALSE);
        DBMS_LOB.OPEN(m_binaryData, DBMS_LOB.LOB_READWRITE);
        m_sourceLength := 0;
        RESULT         := TRUE;
      ELSIF m_mode = 'R'
      THEN
        stmtFetch := 'select ' || m_blobColumn || ' from ' || m_blobTable || ' where ' || m_blobWhere;
        EXECUTE IMMEDIATE stmtFetch
          INTO m_binaryData;
        IF m_binaryData IS NOT NULL
        THEN
          m_sourceLength := dbms_lob.getlength(m_binaryData);
          IF m_sourceLength > 0
          THEN
            RESULT := TRUE;
          ELSE
            m_lastError := 110;
          END IF;
        ELSE
          m_lastError := 111;
        END IF;
      ELSE
        m_lastError := 112;
      END IF; -- mode
    ELSE
      -- too many rows
      m_lastError := 113;
    END IF; -- Hit
    RETURN RESULT;
  END OpenBlob;

  FUNCTION CloseBlob(checksum IN PLS_INTEGER) RETURN BOOLEAN IS
    sourceBlob BLOB;
    stmtFetch  VARCHAR2(2000);
    stmtInit   VARCHAR2(2000);
    RESULT     BOOLEAN := FALSE;
  BEGIN
    IF m_mode = 'W'
    THEN
      m_sourceLength := DBMS_LOB.GETLENGTH(m_binaryData);
    END IF;
  
    -- checksum
    IF checksum = m_sourceLength
    THEN
      IF m_mode = 'W'
      THEN
        -- get the locator to the table blob
        stmtFetch := 'select ' || m_blobColumn || ' from ' || m_blobTable || ' where ' || m_blobWhere ||
                     ' for update';
        EXECUTE IMMEDIATE stmtFetch
          INTO sourceBlob;
      
        -- Check the blob has been initialised
        -- and if it's not empty clear it out
        IF sourceBlob IS NULL
        THEN
          stmtInit := 'update ' || m_blobTable || ' set ' || m_blobColumn || '=EMPTY_BLOB()  where ' ||
                      m_blobWhere;
          EXECUTE IMMEDIATE stmtInit;
          EXECUTE IMMEDIATE stmtFetch
            INTO sourceBlob;
        ELSIF dbms_lob.getlength(sourceBlob) > 0
        THEN
          dbms_lob.TRIM(sourceBlob, 0);
        END IF;
        -- now replace the table data with the temp BLOB
        DBMS_LOB.APPEND(sourceBlob, m_binaryData);
        DBMS_LOB.CLOSE(m_binaryData);
        RESULT := TRUE;
      ELSE
        -- todo
        NULL;
      END IF; --mode
    ELSE
      m_lastError := 115;
    END IF; --checksum
    RETURN RESULT;
  END CloseBlob;

  PROCEDURE WriteData(data IN VARCHAR2) IS
    rawData RAW(16384);
  BEGIN
    rawData := utl_encode.BASE64_DECODE(utl_raw.CAST_TO_RAW(data));
    dbms_lob.WRITEAPPEND(m_binaryData, utl_raw.LENGTH(rawData), rawData);
  END WriteData;

  FUNCTION ReadData RETURN VARCHAR IS
    rawData     RAW(16384);
    bytesToRead PLS_INTEGER;
  BEGIN
    bytesToRead := (m_sourceLength - m_bytesRead);
    IF bytesToRead > MAX_READ_BYTES
    THEN
      bytesToRead := MAX_READ_BYTES;
    END IF;
    DBMS_LOB.READ(m_binaryData, bytesToRead, (m_bytesRead + 1), rawData);
    m_bytesRead := m_bytesRead + bytesToRead;
    RETURN UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(rawData));
  END ReadData;

  FUNCTION GetLastError RETURN PLS_INTEGER IS
  BEGIN
    RETURN m_lastError;
  END GetLastError;

  FUNCTION GetSourceLength RETURN PLS_INTEGER IS
  BEGIN
    RETURN m_sourceLength;
  END GetSourceLength;

  FUNCTION GetSourceChunks RETURN PLS_INTEGER IS
    chunks PLS_INTEGER;
  BEGIN
    chunks := FLOOR(m_sourceLength / MAX_READ_BYTES);
    IF MOD(m_sourceLength, MAX_READ_BYTES) > 0
    THEN
      chunks := chunks + 1;
    END IF;
    RETURN chunks;
  END GetSourceChunks;

END;
/

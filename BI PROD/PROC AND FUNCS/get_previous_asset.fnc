CREATE OR REPLACE FUNCTION Get_Previous_Asset(p_asset_id NUMBER, p_as_header_id NUMBER) RETURN NUMBER IS
 v_asset_id NUMBER;
 BEGIN
 	  SELECT ast.as_asset_id  INTO v_asset_id FROM AS_ASSET ast
						   WHERE ast.P_ASSET_HEADER_ID =  p_as_header_id
						   		 AND ROWNUM=1
								 AND ast.AS_ASSET_ID<p_asset_id
								 ORDER BY ast.AS_ASSET_ID DESC;
	 RETURN v_asset_id;
 EXCEPTION WHEN NO_DATA_FOUND THEN
 		   RETURN NULL;
 END;
/


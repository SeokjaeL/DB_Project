SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    adminId VARCHAR2(255);
    adminPw VARCHAR2(255);
    productCode NUMBER;
    productName VARCHAR2(255);
    productCategory VARCHAR2(255);
    productImage VARCHAR2(255);
    productPrice NUMBER;
    productStock NUMBER;
BEGIN
    -- 관리자 정보 입력 받기
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- 수정할 상품 정보 입력 받기
    productCode := &productCode;
    productName := '&productName';
    productCategory := '&productCategory';
    productImage := '&productImage';
    productPrice := &productPrice;
    productStock := &productStock;
    
    -- 상품 정보 수정 프로시저 호출
    update_product(
        p_adminId => adminId,
        p_adminPw => adminPw,
        p_productCode => productCode,
        p_productName => productName,
        p_productCategory => productCategory,
        p_productImage => productImage,
        p_productPrice => productPrice,
        p_productStock => productStock
    );
END;
/

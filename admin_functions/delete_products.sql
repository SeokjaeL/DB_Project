SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    adminId VARCHAR2(255);
    adminPw VARCHAR2(255);
    productCode NUMBER;
BEGIN
    -- 관리자 정보 입력 받기
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- 삭제할 상품 코드 입력 받기
    productCode := &productCode;

    -- 상품 삭제 프로시저 호출
    delete_product(
        p_adminId => adminId,
        p_adminPw => adminPw,
        p_productCode => productCode
    );
END;
/

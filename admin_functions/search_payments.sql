SET ECHO ON;
SET SERVEROUTPUT ON;

DECLARE
    adminId VARCHAR2(255);
    adminPw VARCHAR2(255);
    receiptId VARCHAR2(255);
BEGIN
    -- 관리자 정보 입력 받기
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- 영수증 번호 입력 받기
    receiptId := '&receiptId';

    -- 결제 목록 검색 프로시저 호출
    search_payments(
        p_adminId => adminId,
        p_adminPw => adminPw,
        p_receiptId => receiptId
    );
END;
/

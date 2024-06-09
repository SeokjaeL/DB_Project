SET ECHO ON;
SET TAB OFF;
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

    -- 결제 취소 프로시저 호출
    cancel_payment(
        p_adminId => adminId,
        p_adminPw => adminPw,
        p_receiptId => receiptId
    );
END;
/

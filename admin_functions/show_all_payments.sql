SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    adminId VARCHAR2(255);
    adminPw VARCHAR2(255);
BEGIN
    -- 관리자 정보 입력 받기
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- 전체 결제 목록 조회 프로시저 호출
    show_all_payments(p_adminId => adminId, p_adminPw => adminPw);
END;
/

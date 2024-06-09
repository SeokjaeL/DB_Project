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

    -- 관리자 삭제 프로시저 호출
    delete_admin(p_adminId => adminId, p_adminPw => adminPw);
END;
/

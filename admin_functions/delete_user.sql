SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    adminId VARCHAR2(255);
    adminPw VARCHAR2(255);
    userId VARCHAR2(255);
BEGIN
    -- 관리자 정보 입력 받기
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- 탈퇴할 회원 아이디 입력 받기
    userId := '&userId';

    -- 회원 탈퇴 처리 프로시저 호출
    delete_user(
        p_adminId => adminId,
        p_adminPw => adminPw,
        p_userId => userId
    );
END;
/

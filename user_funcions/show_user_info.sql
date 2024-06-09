SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    userId VARCHAR2(255);
    userPw VARCHAR2(255);
BEGIN
    -- 사용자로부터 userId와 userPw 입력 받기
    userId := '&userId';
    userPw := '&userPw';
    
    -- 사용자 정보 조회 프로시저 호출
    show_user_info(p_userId => userId, p_userPw => userPw);
END;
/


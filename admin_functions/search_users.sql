SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    adminId VARCHAR2(255);
    adminPw VARCHAR2(255);
    searchUserId VARCHAR2(255);
BEGIN
    -- 관리자 정보 입력 받기
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- 검색할 회원 아이디 입력 받기
    searchUserId := '&searchUserId';
    
    -- 회원 검색 프로시저 호출
    search_users(p_adminId => adminId, p_adminPw => adminPw, p_searchUserId => searchUserId);
END;
/

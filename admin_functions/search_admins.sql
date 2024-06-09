SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    adminId VARCHAR2(255);
    adminPw VARCHAR2(255);
    searchAdminId VARCHAR2(255);
BEGIN
    -- 관리자 정보 입력 받기
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- 검색할 관리자 아이디 입력 받기
    searchAdminId := '&searchAdminId';
    
    -- 관리자 검색 프로시저 호출
    search_admins(p_adminId => adminId, p_adminPw => adminPw, p_searchAdminId => searchAdminId);
END;
/

SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    adminId VARCHAR2(255);
    adminPw VARCHAR2(255);
    targetAdminId VARCHAR2(255);
    newAdminPw VARCHAR2(255);
    newAdminPosition VARCHAR2(255);
BEGIN
    -- 관리자 정보 입력 받기
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- 수정할 관리자 정보 입력 받기
    targetAdminId := '&targetAdminId';
    newAdminPw := '&newAdminPw';
    newAdminPosition := '&newAdminPosition';
    
    -- 관리자 정보 수정 프로시저 호출
    update_admin_info(
        p_adminId => adminId,
        p_adminPw => adminPw,
        p_targetAdminId => targetAdminId,
        p_newAdminPw => newAdminPw,
        p_newAdminPosition => newAdminPosition
    );
END;
/

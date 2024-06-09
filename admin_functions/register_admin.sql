SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    existingAdminId VARCHAR2(255);
    existingAdminPw VARCHAR2(255);
    newAdminId VARCHAR2(255);
    newAdminPw VARCHAR2(255);
    newAdminPosition VARCHAR2(255);
BEGIN
    -- 기존 관리자 정보 입력 받기
    existingAdminId := '&existingAdminId';
    existingAdminPw := '&existingAdminPw';
    
    -- 새로운 관리자 정보 입력 받기
    newAdminId := '&newAdminId';
    newAdminPw := '&newAdminPw';
    newAdminPosition := '&newAdminPosition';

    -- 관리자 등록 프로시저 호출
    register_admin(
        p_existingAdminId => existingAdminId,
        p_existingAdminPw => existingAdminPw,
        p_newAdminId => newAdminId,
        p_newAdminPw => newAdminPw,
        p_newAdminPosition => newAdminPosition
    );
END;
/

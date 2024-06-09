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
    -- ���� ������ ���� �Է� �ޱ�
    existingAdminId := '&existingAdminId';
    existingAdminPw := '&existingAdminPw';
    
    -- ���ο� ������ ���� �Է� �ޱ�
    newAdminId := '&newAdminId';
    newAdminPw := '&newAdminPw';
    newAdminPosition := '&newAdminPosition';

    -- ������ ��� ���ν��� ȣ��
    register_admin(
        p_existingAdminId => existingAdminId,
        p_existingAdminPw => existingAdminPw,
        p_newAdminId => newAdminId,
        p_newAdminPw => newAdminPw,
        p_newAdminPosition => newAdminPosition
    );
END;
/

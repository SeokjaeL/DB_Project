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
    -- ������ ���� �Է� �ޱ�
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- ������ ������ ���� �Է� �ޱ�
    targetAdminId := '&targetAdminId';
    newAdminPw := '&newAdminPw';
    newAdminPosition := '&newAdminPosition';
    
    -- ������ ���� ���� ���ν��� ȣ��
    update_admin_info(
        p_adminId => adminId,
        p_adminPw => adminPw,
        p_targetAdminId => targetAdminId,
        p_newAdminPw => newAdminPw,
        p_newAdminPosition => newAdminPosition
    );
END;
/

SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    adminId VARCHAR2(255);
    adminPw VARCHAR2(255);
BEGIN
    -- ������ ���� �Է� �ޱ�
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- ������ ���� ��ȸ ���ν��� ȣ��
    show_admin_info(p_adminId => adminId, p_adminPw => adminPw);
END;
/

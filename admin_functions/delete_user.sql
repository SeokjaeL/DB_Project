SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    adminId VARCHAR2(255);
    adminPw VARCHAR2(255);
    userId VARCHAR2(255);
BEGIN
    -- ������ ���� �Է� �ޱ�
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- Ż���� ȸ�� ���̵� �Է� �ޱ�
    userId := '&userId';

    -- ȸ�� Ż�� ó�� ���ν��� ȣ��
    delete_user(
        p_adminId => adminId,
        p_adminPw => adminPw,
        p_userId => userId
    );
END;
/

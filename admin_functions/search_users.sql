SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    adminId VARCHAR2(255);
    adminPw VARCHAR2(255);
    searchUserId VARCHAR2(255);
BEGIN
    -- ������ ���� �Է� �ޱ�
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- �˻��� ȸ�� ���̵� �Է� �ޱ�
    searchUserId := '&searchUserId';
    
    -- ȸ�� �˻� ���ν��� ȣ��
    search_users(p_adminId => adminId, p_adminPw => adminPw, p_searchUserId => searchUserId);
END;
/

SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    adminId VARCHAR2(255);
    adminPw VARCHAR2(255);
    searchAdminId VARCHAR2(255);
BEGIN
    -- ������ ���� �Է� �ޱ�
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- �˻��� ������ ���̵� �Է� �ޱ�
    searchAdminId := '&searchAdminId';
    
    -- ������ �˻� ���ν��� ȣ��
    search_admins(p_adminId => adminId, p_adminPw => adminPw, p_searchAdminId => searchAdminId);
END;
/

SET ECHO ON;
SET SERVEROUTPUT ON;

DECLARE
    adminId VARCHAR2(255);
    adminPw VARCHAR2(255);
    receiptId VARCHAR2(255);
BEGIN
    -- ������ ���� �Է� �ޱ�
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- ������ ��ȣ �Է� �ޱ�
    receiptId := '&receiptId';

    -- ���� ��� �˻� ���ν��� ȣ��
    search_payments(
        p_adminId => adminId,
        p_adminPw => adminPw,
        p_receiptId => receiptId
    );
END;
/

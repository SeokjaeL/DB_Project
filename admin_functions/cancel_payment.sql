SET ECHO ON;
SET TAB OFF;
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

    -- ���� ��� ���ν��� ȣ��
    cancel_payment(
        p_adminId => adminId,
        p_adminPw => adminPw,
        p_receiptId => receiptId
    );
END;
/

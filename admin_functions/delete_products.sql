SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    adminId VARCHAR2(255);
    adminPw VARCHAR2(255);
    productCode NUMBER;
BEGIN
    -- ������ ���� �Է� �ޱ�
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- ������ ��ǰ �ڵ� �Է� �ޱ�
    productCode := &productCode;

    -- ��ǰ ���� ���ν��� ȣ��
    delete_product(
        p_adminId => adminId,
        p_adminPw => adminPw,
        p_productCode => productCode
    );
END;
/

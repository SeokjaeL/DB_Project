SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    adminId VARCHAR2(255);
    adminPw VARCHAR2(255);
    productCode NUMBER;
    productName VARCHAR2(255);
    productCategory VARCHAR2(255);
    productImage VARCHAR2(255);
    productPrice NUMBER;
    productStock NUMBER;
BEGIN
    -- ������ ���� �Է� �ޱ�
    adminId := '&adminId';
    adminPw := '&adminPw';
    
    -- ������ ��ǰ ���� �Է� �ޱ�
    productCode := &productCode;
    productName := '&productName';
    productCategory := '&productCategory';
    productImage := '&productImage';
    productPrice := &productPrice;
    productStock := &productStock;
    
    -- ��ǰ ���� ���� ���ν��� ȣ��
    update_product(
        p_adminId => adminId,
        p_adminPw => adminPw,
        p_productCode => productCode,
        p_productName => productName,
        p_productCategory => productCategory,
        p_productImage => productImage,
        p_productPrice => productPrice,
        p_productStock => productStock
    );
END;
/

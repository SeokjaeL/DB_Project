SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    userId VARCHAR2(255);
    userPw VARCHAR2(255);
    productCode NUMBER;
    amount NUMBER;
    usePoint NUMBER;
BEGIN
    -- ���� ���� �Է� �ޱ�
    userId := '&userId';
    userPw := '&userPw';
    productCode := &productCode;
    amount := &amount;
    usePoint := &usePoint;

    -- ���� ���ν��� ȣ��
    make_payment(
        p_userId => userId,
        p_userPw => userPw,
        p_productCode => productCode,
        p_amount => amount,
        p_usePoint => usePoint
    );
END;
/

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
    -- 결제 정보 입력 받기
    userId := '&userId';
    userPw := '&userPw';
    productCode := &productCode;
    amount := &amount;
    usePoint := &usePoint;

    -- 결제 프로시저 호출
    make_payment(
        p_userId => userId,
        p_userPw => userPw,
        p_productCode => productCode,
        p_amount => amount,
        p_usePoint => usePoint
    );
END;
/

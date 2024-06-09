SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    userId VARCHAR2(255);
    currentPw VARCHAR2(255);
    newPw VARCHAR2(255);
    userBirthday DATE;
    userAddress VARCHAR2(255);
    userDetail_address VARCHAR2(255);
    userEmail VARCHAR2(255);
    userName VARCHAR2(255);
    userPhone VARCHAR2(20);
BEGIN
    -- ����� ���� �Է� �ޱ�
    userId := '&userId';
    currentPw := '&currentPw';
    newPw := '&newPw';
    userBirthday := TO_DATE('&userBirthday', 'YYYY-MM-DD');
    userAddress := '&userAddress';
    userDetail_address := '&userDetail_address';
    userEmail := '&userEmail';
    userName := '&userName';
    userPhone := '&userPhone';
    
    -- ����� ���� ������Ʈ ���ν��� ȣ��
    update_user_info(
        p_userId => userId,
        p_currentPw => currentPw,
        p_newPw => newPw,
        p_userBirthday => userBirthday,
        p_userAddress => userAddress,
        p_userDetail_address => userDetail_address,
        p_userEmail => userEmail,
        p_userName => userName,
        p_userPhone => userPhone
    );
END;
/

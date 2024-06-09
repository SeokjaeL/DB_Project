SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    userId VARCHAR2(255);
    userPassword VARCHAR2(255);
    isValid NUMBER;
    userBirthday DATE;
    userJoinDate TIMESTAMP;
    userAddress VARCHAR2(255);
    userDetail_address VARCHAR2(255);
    userEmail VARCHAR2(255);
    userName VARCHAR2(255);
    userPhone VARCHAR2(20);
    userPoint NUMBER;
BEGIN
        -- ȸ�� ���� ���� �Է� �ޱ� 
        userId := '&userId';
        userPassword := '&userPassword';
        userBirthday := TO_DATE('&userBirthday', 'YYYY-MM-DD');
        userJoinDate := CURRENT_TIMESTAMP;
        userAddress := '&userAddress';
        userDetail_address := '&userDetail_address';
        userEmail := '&userEmail';
        userName := '&userName';
        userPhone := '&userPhone';

        -- ȸ������ ���ν����� ȣ���ؼ� �Է��� ȸ�� ���� ����
        register_user(
            p_userId => userId,
            p_userPw => userPassword,
            p_userBirthday => userBirthday,
            p_userJoinDate => userJoinDate,
            p_userAddress => userAddress,
            p_userDetail_address => userDetail_address,
            p_userEmail => userEmail,
            p_userName => userName,
            p_userPhone => userPhone
        );
END;
/
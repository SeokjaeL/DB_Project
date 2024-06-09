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
        -- 회원 가입 정보 입력 받기 
        userId := '&userId';
        userPassword := '&userPassword';
        userBirthday := TO_DATE('&userBirthday', 'YYYY-MM-DD');
        userJoinDate := CURRENT_TIMESTAMP;
        userAddress := '&userAddress';
        userDetail_address := '&userDetail_address';
        userEmail := '&userEmail';
        userName := '&userName';
        userPhone := '&userPhone';

        -- 회원가입 프로시저를 호출해서 입력한 회원 정보 저장
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
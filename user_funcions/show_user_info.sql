SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    userId VARCHAR2(255);
    userPw VARCHAR2(255);
BEGIN
    -- ����ڷκ��� userId�� userPw �Է� �ޱ�
    userId := '&userId';
    userPw := '&userPw';
    
    -- ����� ���� ��ȸ ���ν��� ȣ��
    show_user_info(p_userId => userId, p_userPw => userPw);
END;
/


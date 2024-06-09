-- ȸ�� ���� ���ν���
CREATE OR REPLACE PROCEDURE register_user (
    p_userId IN VARCHAR2,
    p_userPw IN VARCHAR2,
    p_userBirthday IN DATE,
    p_userJoinDate IN TIMESTAMP,
    p_userAddress IN VARCHAR2,
    p_userDetail_address IN VARCHAR2,
    p_userEmail IN VARCHAR2,
    p_userName IN VARCHAR2,
    p_userPhone IN VARCHAR2
) IS
    v_isValid NUMBER := 1; -- �⺻���� 1��
    v_hashedPw RAW(32); -- ��й�ȣ ��ȣȭ ����
    v_userPoint NUMBER := 50;
BEGIN
    -- ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_userPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- users ���̺� �Է¹��� ȸ������ �Է�
    INSERT INTO users (
        userId, userPw, isValid, userBirthday, userJoinDate, userAddress,
        userDetail_address, userEmail, userName, userPhone, userPoint
    ) VALUES (
        p_userId, RAWTOHEX(v_hashedPw), v_isValid, p_userBirthday, p_userJoinDate, p_userAddress,
        p_userDetail_address, p_userEmail, p_userName, p_userPhone, v_userPoint
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('ȸ�������� �Ϸ�Ǿ����ϴ�.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- ������ ��� ���ν���
CREATE OR REPLACE PROCEDURE register_admin (
    p_existingAdminId IN VARCHAR2,
    p_existingAdminPw IN VARCHAR2,
    p_newAdminId IN VARCHAR2,
    p_newAdminPw IN VARCHAR2,
    p_newAdminPosition IN VARCHAR2
) IS
    v_existingHashedPw RAW(32);
    v_newHashedPw RAW(32);
    v_adminCount NUMBER := 0;
BEGIN
    -- ���� ������ ��й�ȣ�� SHA-256���� �ؽ�
    v_existingHashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_existingAdminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- ���� ������ ��ȿ�� Ȯ��
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_existingAdminId
    AND adminPassword = RAWTOHEX(v_existingHashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �α��ο� �����߽��ϴ�.');
    ELSE
        -- ���ο� ������ ��й�ȣ�� SHA-256���� �ؽ�
        v_newHashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_newAdminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
        
        -- ���ο� ������ ���� ����
        INSERT INTO admins (adminId, adminPassword, adminPosition)
        VALUES (p_newAdminId, RAWTOHEX(v_newHashedPw), p_newAdminPosition);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('�� ������ ����� �Ϸ�Ǿ����ϴ�.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- ȸ�� ���� ��� ���ν���
CREATE OR REPLACE PROCEDURE show_user_info (
    p_userId IN VARCHAR2,
    p_userPw IN VARCHAR2
) IS
    v_hashedPw RAW(32);
    v_userCount NUMBER := 0;
    v_isValid NUMBER;
    v_userBirthday DATE;
    v_userJoinDate TIMESTAMP;
    v_userAddress VARCHAR2(255);
    v_userDetail_address VARCHAR2(255);
    v_userEmail VARCHAR2(255);
    v_userName VARCHAR2(255);
    v_userPhone VARCHAR2(20);
    v_userPoint NUMBER;
BEGIN
    -- ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_userPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- ����� ��ȿ�� Ȯ��
    SELECT COUNT(*)
    INTO v_userCount
    FROM users
    WHERE userId = p_userId
    AND userPw = RAWTOHEX(v_hashedPw);

    IF v_userCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ȸ�� �α��ο� �����߽��ϴ�.');
    ELSE
        -- ����� ���� ��ȸ
        SELECT isValid, userBirthday, userJoinDate, userAddress, userDetail_address, userEmail, userName, userPhone, userPoint
        INTO v_isValid, v_userBirthday, v_userJoinDate, v_userAddress, v_userDetail_address, v_userEmail, v_userName, v_userPhone, v_userPoint
        FROM users
        WHERE userId = p_userId;

        -- isValid ���� 0�� ��� ��ȿ���� ���� ȸ�� �޽��� ���
        IF v_isValid = 0 THEN
            DBMS_OUTPUT.PUT_LINE('��ȿ���� ���� ȸ���Դϴ�.');
        ELSE
            -- ����� ���� ���
            DBMS_OUTPUT.PUT_LINE('�ش��ϴ� ȸ�� �����Դϴ�.');
            DBMS_OUTPUT.PUT_LINE('User ID: ' || p_userId);
            DBMS_OUTPUT.PUT_LINE('Is Valid: ' || v_isValid);
            DBMS_OUTPUT.PUT_LINE('Birthday: ' || v_userBirthday);
            DBMS_OUTPUT.PUT_LINE('Join Date: ' || v_userJoinDate);
            DBMS_OUTPUT.PUT_LINE('Address: ' || v_userAddress);
            DBMS_OUTPUT.PUT_LINE('Detail Address: ' || v_userDetail_address);
            DBMS_OUTPUT.PUT_LINE('Email: ' || v_userEmail);
            DBMS_OUTPUT.PUT_LINE('Name: ' || v_userName);
            DBMS_OUTPUT.PUT_LINE('Phone: ' || v_userPhone);
            DBMS_OUTPUT.PUT_LINE('Point: ' || v_userPoint);
        END IF;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('����ڸ� ã�� �� �����ϴ�: ' || p_userId);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        RAISE;
END;
/

-- ȸ�� ���� ���� ���ν���
CREATE OR REPLACE PROCEDURE update_user_info (
    p_userId IN VARCHAR2,
    p_currentPw IN VARCHAR2,
    p_newPw IN VARCHAR2,
    p_userBirthday IN DATE,
    p_userAddress IN VARCHAR2,
    p_userDetail_address IN VARCHAR2,
    p_userEmail IN VARCHAR2,
    p_userName IN VARCHAR2,
    p_userPhone IN VARCHAR2
) IS
    v_hashedCurrentPw RAW(32);
    v_hashedNewPw RAW(32);
    v_userCount NUMBER := 0;
    v_isValid NUMBER;
BEGIN
    -- ���� ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedCurrentPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_currentPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    
    BEGIN
        -- ����� ��ȿ�� �� ���� ��й�ȣ Ȯ��
        SELECT COUNT(*), isValid
        INTO v_userCount, v_isValid
        FROM users
        WHERE userId = p_userId
        AND userPw = RAWTOHEX(v_hashedCurrentPw)
        GROUP BY isValid;

        IF v_userCount = 0 THEN
            DBMS_OUTPUT.PUT_LINE('ȸ�� �α��ο� �����߽��ϴ�.');
        ELSIF v_isValid = 0 THEN
            DBMS_OUTPUT.PUT_LINE('��ȿ���� ���� ȸ���Դϴ�.');
        ELSE
            -- �� ��й�ȣ�� SHA-256���� �ؽ�
            v_hashedNewPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_newPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

            -- ����� ���� ������Ʈ
            UPDATE users
            SET userPw = RAWTOHEX(v_hashedNewPw),
                userBirthday = p_userBirthday,
                userAddress = p_userAddress,
                userDetail_address = p_userDetail_address,
                userEmail = p_userEmail,
                userName = p_userName,
                userPhone = p_userPhone
            WHERE userId = p_userId;
            
            -- ��� �޽��� ���
            IF SQL%ROWCOUNT > 0 THEN
                COMMIT;
                DBMS_OUTPUT.PUT_LINE('����� ������ ���������� ������Ʈ�Ǿ����ϴ�.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('����� ���� ������Ʈ�� �����߽��ϴ�: ' || p_userId);
            END IF;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('ȸ�� �α��ο� �����߽��ϴ�.');
    END;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- ��ǰ ��� ���ν���
CREATE OR REPLACE PROCEDURE register_product (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2,
    p_productName IN VARCHAR2,
    p_productCategory IN VARCHAR2,
    p_productImage IN VARCHAR2,
    p_productPrice IN NUMBER,
    p_productStock IN NUMBER
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;
BEGIN
    -- ������ ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    
    -- ������ �α��� Ȯ��
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);
    
    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �α��ο� �����߽��ϴ�.');
    ELSE
        -- ��ǰ ���� ���
        INSERT INTO products (productName, productCategory, productImage, productPrice, productStock)
        VALUES (p_productName, p_productCategory, p_productImage, p_productPrice, p_productStock);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('��ǰ�� ���������� ��ϵǾ����ϴ�.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- ��ü ��ǰ ��� ��� ���ν���
CREATE OR REPLACE PROCEDURE show_all_products IS
    CURSOR product_cursor IS
        SELECT productCode, productName, productCategory, productImage, productPrice, productStock
        FROM products;
    
    v_product product_cursor%ROWTYPE;
BEGIN
    -- ��ǰ ���� ��� ����
    DBMS_OUTPUT.PUT_LINE('��ϵ� ��ǰ ���:');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('�ڵ� | �̸� | ī�װ� | �̹��� URL | ���� | ���');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------');

    -- Ŀ�� ���� �� ��ǰ ���� ��ȸ
    OPEN product_cursor;
    LOOP
        FETCH product_cursor INTO v_product;
        EXIT WHEN product_cursor%NOTFOUND;

        -- ��ǰ ���� ���
        DBMS_OUTPUT.PUT_LINE(
            v_product.productCode || ' | ' ||
            v_product.productName || ' | ' ||
            v_product.productCategory || ' | ' ||
            v_product.productImage || ' | ' ||
            v_product.productPrice || ' | ' ||
            v_product.productStock
        );
    END LOOP;

    -- Ŀ�� �ݱ�
    CLOSE product_cursor;
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        RAISE;
END;
/

-- ��ǰ �˻� ���ν���
CREATE OR REPLACE PROCEDURE search_products (
    p_search_mode IN NUMBER,
    p_search_value IN VARCHAR2
) IS
    CURSOR product_cursor IS
        SELECT productCode, productName, productCategory, productImage, productPrice, productStock
        FROM products
        WHERE (p_search_mode = 1 AND productName LIKE '%' || p_search_value || '%')
           OR (p_search_mode = 2 AND productCategory LIKE '%' || p_search_value || '%');
    
    v_product product_cursor%ROWTYPE;
BEGIN
    -- ��ǰ �˻� ��� ��� ����
    DBMS_OUTPUT.PUT_LINE('�˻� ���:');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('�ڵ� | �̸� | ī�װ� | �̹��� URL | ���� | ���');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------');

    -- Ŀ�� ���� �� ��ǰ ���� ��ȸ
    OPEN product_cursor;
    LOOP
        FETCH product_cursor INTO v_product;
        EXIT WHEN product_cursor%NOTFOUND;

        -- ��ǰ ���� ���
        DBMS_OUTPUT.PUT_LINE(
            v_product.productCode || ' | ' ||
            v_product.productName || ' | ' ||
            v_product.productCategory || ' | ' ||
            v_product.productImage || ' | ' ||
            v_product.productPrice || ' | ' ||
            v_product.productStock
        );
    END LOOP;

    -- Ŀ�� �ݱ�
    CLOSE product_cursor;
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        RAISE;
END;
/

-- ������ ���� ���ν���
CREATE OR REPLACE PROCEDURE delete_admin (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;
BEGIN
    -- ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    
    -- ������ ���� ���� Ȯ��
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('�߸��� ������ ������ �Է��Ͽ����ϴ�.');
    ELSE
        -- ������ ����
        DELETE FROM admins
        WHERE adminId = p_adminId
        AND adminPassword = RAWTOHEX(v_hashedPw);

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('�����ڰ� ���������� �����Ǿ����ϴ�.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- ��ǰ ���� ���ν���
CREATE OR REPLACE PROCEDURE delete_product (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2,
    p_productCode IN NUMBER
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;
BEGIN
    -- ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    
    -- ������ �α��� Ȯ��
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);
    
    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �α��ο� �����߽��ϴ�.');
    ELSE
        -- ��ǰ ����
        DELETE FROM products
        WHERE productCode = p_productCode;
        
        IF SQL%ROWCOUNT > 0 THEN
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('��ǰ�� ���������� �����Ǿ����ϴ�.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('�ش� ��ǰ�� ã�� �� �����ϴ�: ' || p_productCode);
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- ��ü ȸ�� ��� ��� ���ν���
CREATE OR REPLACE PROCEDURE show_all_users (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;
    
    CURSOR user_cursor IS
        SELECT userId, isValid, userBirthday, userJoinDate, userAddress, userDetail_address, userEmail, userName, userPhone, userPoint
        FROM users;

    v_user user_cursor%ROWTYPE;
BEGIN
    -- ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- ������ �α��� Ȯ��
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �α��ο� �����߽��ϴ�.');
    ELSE
        -- ȸ�� ��� ��� ����
        DBMS_OUTPUT.PUT_LINE('��ü ȸ�� ���:');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('���̵� | ��ȿ�� | ������� | ������ | �ּ� | �� �ּ� | �̸��� | �̸� | ��ȭ��ȣ | ����Ʈ');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------');

        -- Ŀ�� ���� �� ȸ�� ���� ��ȸ
        OPEN user_cursor;
        LOOP
            FETCH user_cursor INTO v_user;
            EXIT WHEN user_cursor%NOTFOUND;

            -- ȸ�� ���� ���
            DBMS_OUTPUT.PUT_LINE(
                v_user.userId || ' | ' ||
                v_user.isValid || ' | ' ||
                v_user.userBirthday || ' | ' ||
                v_user.userJoinDate || ' | ' ||
                v_user.userAddress || ' | ' ||
                v_user.userDetail_address || ' | ' ||
                v_user.userEmail || ' | ' ||
                v_user.userName || ' | ' ||
                v_user.userPhone || ' | ' ||
                v_user.userPoint
            );
        END LOOP;

        -- Ŀ�� �ݱ�
        CLOSE user_cursor;
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        RAISE;
END;
/
-- ȸ�� Ż�� ���ν���
CREATE OR REPLACE PROCEDURE delete_user (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2,
    p_userId IN VARCHAR2
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;
    v_isValid NUMBER := 0;
BEGIN
    -- ������ ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- ������ ��ȿ�� Ȯ��
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �α��ο� �����߽��ϴ�.');
    ELSE
        -- ȸ�� ���� �� ���� Ȯ��
        SELECT isValid
        INTO v_isValid
        FROM users
        WHERE userId = p_userId;

        IF SQL%NOTFOUND THEN
            DBMS_OUTPUT.PUT_LINE('�������� �ʴ� ȸ���Դϴ�.');
        ELSIF v_isValid = 0 THEN
            DBMS_OUTPUT.PUT_LINE('�̹� Ż��ó���� ȸ���Դϴ�.');
        ELSE
            -- ȸ�� Ż�� ó��
            UPDATE users
            SET isValid = 0
            WHERE userId = p_userId;

            COMMIT;
            DBMS_OUTPUT.PUT_LINE('ȸ�� Ż�� ó���� �Ϸ�Ǿ����ϴ�.');
        END IF;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('�������� �ʴ� ȸ���Դϴ�.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- ȸ�� ���� ���� ���ν���
CREATE OR REPLACE PROCEDURE update_product (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2,
    p_productCode IN NUMBER,
    p_productName IN VARCHAR2,
    p_productCategory IN VARCHAR2,
    p_productImage IN VARCHAR2,
    p_productPrice IN NUMBER,
    p_productStock IN NUMBER
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;
BEGIN
    -- ������ ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    
    -- ������ �α��� Ȯ��
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);
    
    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �α��ο� �����߽��ϴ�.');
    ELSE
        -- ��ǰ ���� ����
        UPDATE products
        SET productName = p_productName,
            productCategory = p_productCategory,
            productImage = p_productImage,
            productPrice = p_productPrice,
            productStock = p_productStock
        WHERE productCode = p_productCode;

        -- ��� �޽��� ���
        IF SQL%ROWCOUNT > 0 THEN
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('��ǰ ������ ���������� �����Ǿ����ϴ�.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('�ش� ��ǰ�� ã�� �� �����ϴ�: ' || p_productCode);
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- ������ ���� ���� ���ν���
CREATE OR REPLACE PROCEDURE update_admin_info (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2,
    p_targetAdminId IN VARCHAR2,
    p_newAdminPw IN VARCHAR2,
    p_newAdminPosition IN VARCHAR2
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;
    v_newHashedPw RAW(32);
BEGIN
    -- ������ ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    
    -- ������ ��ȿ�� Ȯ��
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);
    
    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �α��ο� �����߽��ϴ�.');
    ELSE
        -- ������ ������ ��й�ȣ�� SHA-256���� �ؽ�
        v_newHashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_newAdminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
        
        -- ������ ���� ����
        UPDATE admins
        SET adminPassword = RAWTOHEX(v_newHashedPw),
            adminPosition = p_newAdminPosition
        WHERE adminId = p_targetAdminId;
        
        -- ��� �޽��� ���
        IF SQL%ROWCOUNT > 0 THEN
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('������ ������ ���������� �����Ǿ����ϴ�.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('�ش� �����ڸ� ã�� �� �����ϴ�: ' || p_targetAdminId);
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- ������ ���� ��� ���ν���
CREATE OR REPLACE PROCEDURE show_admin_info (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;
    v_adminPosition VARCHAR2(255);
BEGIN
    -- ������ ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    
    -- ������ ��ȿ�� Ȯ��
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);
    
    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �α��ο� �����߽��ϴ�.');
    ELSE
        -- ������ ���� ��ȸ
        SELECT adminPosition
        INTO v_adminPosition
        FROM admins
        WHERE adminId = p_adminId;
        
        -- ������ ���� ���
        DBMS_OUTPUT.PUT_LINE('������ ����:');
        DBMS_OUTPUT.PUT_LINE('������ ID: ' || p_adminId);
        DBMS_OUTPUT.PUT_LINE('��å: ' || v_adminPosition);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('�����ڸ� ã�� �� �����ϴ�: ' || p_adminId);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        RAISE;
END;
/

-- ��ü ������ ��� ��� ���ν���
CREATE OR REPLACE PROCEDURE show_all_admins (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;

    CURSOR admin_cursor IS
        SELECT adminId, adminPosition
        FROM admins;

    v_admin admin_cursor%ROWTYPE;
BEGIN
    -- ������ ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- ������ ��ȿ�� Ȯ��
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �α��ο� �����߽��ϴ�.');
    ELSE
        -- ������ ��� ��� ����
        DBMS_OUTPUT.PUT_LINE('��ü ������ ���:');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('������ ID | ��å');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');

        -- Ŀ�� ���� �� ������ ���� ��ȸ
        OPEN admin_cursor;
        LOOP
            FETCH admin_cursor INTO v_admin;
            EXIT WHEN admin_cursor%NOTFOUND;

            -- ������ ���� ���
            DBMS_OUTPUT.PUT_LINE(v_admin.adminId || ' | ' || v_admin.adminPosition);
        END LOOP;

        -- Ŀ�� �ݱ�
        CLOSE admin_cursor;
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        RAISE;
END;
/

-- ������ �˻� ���ν���
CREATE OR REPLACE PROCEDURE search_admins (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2,
    p_searchAdminId IN VARCHAR2
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;

    CURSOR admin_cursor IS
        SELECT adminId, adminPosition
        FROM admins
        WHERE adminId LIKE '%' || p_searchAdminId || '%';

    v_admin admin_cursor%ROWTYPE;
BEGIN
    -- ������ ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- ������ ��ȿ�� Ȯ��
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �α��ο� �����߽��ϴ�.');
    ELSE
        -- ������ �˻� ��� ��� ����
        DBMS_OUTPUT.PUT_LINE('�˻��� ������ ���:');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('������ ID | ��å');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');

        -- Ŀ�� ���� �� ������ ���� ��ȸ
        OPEN admin_cursor;
        LOOP
            FETCH admin_cursor INTO v_admin;
            EXIT WHEN admin_cursor%NOTFOUND;

            -- ������ ���� ���
            DBMS_OUTPUT.PUT_LINE(v_admin.adminId || ' | ' || v_admin.adminPosition);
        END LOOP;

        -- Ŀ�� �ݱ�
        CLOSE admin_cursor;
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        RAISE;
END;
/

-- ȸ�� �˻� ���ν���
CREATE OR REPLACE PROCEDURE search_users (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2,
    p_searchUserId IN VARCHAR2
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;

    CURSOR user_cursor IS
        SELECT userId, isValid, userBirthday, userJoinDate, userAddress, userDetail_address, userEmail, userName, userPhone, userPoint
        FROM users
        WHERE userId LIKE '%' || p_searchUserId || '%';

    v_user user_cursor%ROWTYPE;
BEGIN
    -- ������ ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- ������ ��ȿ�� Ȯ��
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �α��ο� �����߽��ϴ�.');
    ELSE
        -- ȸ�� �˻� ��� ��� ����
        DBMS_OUTPUT.PUT_LINE('�˻��� ȸ�� ���:');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('���̵� | ��ȿ�� | ������� | ������ | �ּ� | �� �ּ� | �̸��� | �̸� | ��ȭ��ȣ | ����Ʈ');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------');

        -- Ŀ�� ���� �� ȸ�� ���� ��ȸ
        OPEN user_cursor;
        LOOP
            FETCH user_cursor INTO v_user;
            EXIT WHEN user_cursor%NOTFOUND;

            -- ȸ�� ���� ���
            DBMS_OUTPUT.PUT_LINE(
                v_user.userId || ' | ' ||
                v_user.isValid || ' | ' ||
                v_user.userBirthday || ' | ' ||
                v_user.userJoinDate || ' | ' ||
                v_user.userAddress || ' | ' ||
                v_user.userDetail_address || ' | ' ||
                v_user.userEmail || ' | ' ||
                v_user.userName || ' | ' ||
                v_user.userPhone || ' | ' ||
                v_user.userPoint
            );
        END LOOP;

        -- Ŀ�� �ݱ�
        CLOSE user_cursor;
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        RAISE;
END;
/

-- ��ü ���� ��� ��� ���ν���
CREATE OR REPLACE PROCEDURE show_all_payments (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;

    CURSOR payment_cursor IS
        SELECT receipt_id, userId, usePoint, productCode, amount, isValid, payDay, totalPrice
        FROM payments;

    v_payment payment_cursor%ROWTYPE;
BEGIN
    -- ������ ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- ������ ��ȿ�� Ȯ��
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �α��ο� �����߽��ϴ�.');
    ELSE
        -- ���� ��� ��� ����
        DBMS_OUTPUT.PUT_LINE('��ü ���� ���:');
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('������ ID | ����� ID | ���� ����Ʈ | ��ǰ �ڵ� | ���� | ��ȿ�� | ������ | �� ����');
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------');

        -- Ŀ�� ���� �� ���� ���� ��ȸ
        OPEN payment_cursor;
        LOOP
            FETCH payment_cursor INTO v_payment;
            EXIT WHEN payment_cursor%NOTFOUND;

            -- ���� ���� ���
            DBMS_OUTPUT.PUT_LINE(
                v_payment.receipt_id || ' | ' ||
                v_payment.userId || ' | ' ||
                v_payment.usePoint || ' | ' ||
                v_payment.productCode || ' | ' ||
                v_payment.amount || ' | ' ||
                v_payment.isValid || ' | ' ||
                v_payment.payDay || ' | ' ||
                v_payment.totalPrice
            );
        END LOOP;

        -- Ŀ�� �ݱ�
        CLOSE payment_cursor;
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        RAISE;
END;
/

-- ���� ���ν���
CREATE OR REPLACE PROCEDURE make_payment (
    p_userId IN VARCHAR2,
    p_userPw IN VARCHAR2,
    p_productCode IN NUMBER,
    p_amount IN NUMBER,
    p_usePoint IN NUMBER
) IS
    v_hashedPw RAW(32);
    v_userCount NUMBER := 0;
    v_isValid NUMBER;
    v_productPrice NUMBER;
    v_productStock NUMBER;
    v_totalPrice NUMBER;
    v_earnedPoints NUMBER;
    v_newPoints NUMBER;
    v_receiptId VARCHAR2(20); -- ������ ID�� ũ�⸦ �ø�
    v_payDay TIMESTAMP := SYSTIMESTAMP;

    FUNCTION generate_receipt_id RETURN VARCHAR2 IS
        v_alpha VARCHAR2(4);
        v_num VARCHAR2(6);
    BEGIN
        -- Generate 4-letter random alphabetic string
        v_alpha := SUBSTR(DBMS_RANDOM.STRING('U', 4), 1, 4);
        -- Generate 6-digit random numeric string
        v_num := TO_CHAR(FLOOR(DBMS_RANDOM.VALUE(100000, 999999)));
        RETURN v_alpha || v_num;
    END;

BEGIN
    -- ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_userPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- ����� ��ȿ�� �� ��й�ȣ Ȯ��
    SELECT COUNT(*), isValid, userPoint
    INTO v_userCount, v_isValid, v_newPoints
    FROM users
    WHERE userId = p_userId
    AND userPw = RAWTOHEX(v_hashedPw)
    GROUP BY isValid, userPoint;

    IF v_userCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ȸ�� �α��ο� �����߽��ϴ�.');
        RETURN;
    ELSIF v_isValid = 0 THEN
        DBMS_OUTPUT.PUT_LINE('��ȿ���� ���� ȸ���Դϴ�.');
        RETURN;
    END IF;

    -- ��ǰ ���� Ȯ�� �� ��� Ȯ��
    SELECT productPrice, productStock
    INTO v_productPrice, v_productStock
    FROM products
    WHERE productCode = p_productCode;

    IF v_productStock < p_amount THEN
        DBMS_OUTPUT.PUT_LINE('��� �����մϴ�.');
        RETURN;
    END IF;

    -- ��� ������Ʈ
    UPDATE products
    SET productStock = productStock - p_amount
    WHERE productCode = p_productCode;

    -- �� �����ݾ� ���
    v_totalPrice := v_productPrice * p_amount;

    -- ����Ʈ ���� ��� (1% ����)
    v_earnedPoints := ROUND(v_totalPrice * 0.01);

    -- ����� ����Ʈ ������Ʈ
    v_newPoints := v_newPoints - p_usePoint + v_earnedPoints;
    UPDATE users
    SET userPoint = v_newPoints
    WHERE userId = p_userId;

    -- ������ ��ȣ ����
    v_receiptId := generate_receipt_id;

    -- ���� ���� ����
    INSERT INTO payments (
        receipt_id, userId, usePoint, productCode, amount, isValid, payDay, totalPrice
    ) VALUES (
        v_receiptId, p_userId, p_usePoint, p_productCode, p_amount, 1, v_payDay, v_totalPrice
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('������ �Ϸ�Ǿ����ϴ�. ������ ��ȣ: ' || v_receiptId);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('�������� �ʴ� ����� �Ǵ� ��ǰ�Դϴ�.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- ���� ��� ���ν���
CREATE OR REPLACE PROCEDURE cancel_payment (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2,
    p_receiptId IN VARCHAR2
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;
    v_isValid NUMBER;
    v_productCode NUMBER;
    v_amount NUMBER;
    v_usePoint NUMBER;
    v_userId VARCHAR2(255);
    v_totalPrice NUMBER;
    v_earnedPoints NUMBER;
    v_userPoint NUMBER;
BEGIN
    -- ������ ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- ������ ��ȿ�� Ȯ��
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �α��ο� �����߽��ϴ�.');
        RETURN;
    END IF;

    -- �������� ��ȿ�� Ȯ�� �� ���� ���� ��������
    SELECT isValid, productCode, amount, usePoint, userId, totalPrice
    INTO v_isValid, v_productCode, v_amount, v_usePoint, v_userId, v_totalPrice
    FROM payments
    WHERE receipt_id = p_receiptId;

    IF v_isValid = 0 THEN
        DBMS_OUTPUT.PUT_LINE('�̹� ȯ�ҵ� �������Դϴ�.');
        RETURN;
    END IF;

    -- ���� ��ȿ�� ���
    UPDATE payments
    SET isValid = 0
    WHERE receipt_id = p_receiptId;

    -- ��ǰ ��� ����ġ
    UPDATE products
    SET productStock = productStock + v_amount
    WHERE productCode = v_productCode;

    -- ����Ʈ ��� (���� �ݾ��� 1% ������ ���� ��ȯ)
    v_earnedPoints := ROUND(v_totalPrice * 0.01);

    -- ����� ����Ʈ ������Ʈ
    SELECT userPoint INTO v_userPoint FROM users WHERE userId = v_userId;
    v_userPoint := v_userPoint + v_usePoint - v_earnedPoints;
    UPDATE users
    SET userPoint = v_userPoint
    WHERE userId = v_userId;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('������ ���������� ��ҵǾ����ϴ�. ������ ��ȣ: ' || p_receiptId);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('�������� �ʴ� ������ ��ȣ�Դϴ�: ' || p_receiptId);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- ���� �˻� ���ν���
CREATE OR REPLACE PROCEDURE search_payments (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2,
    p_receiptId IN VARCHAR2
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;

    CURSOR payment_cursor IS
        SELECT receipt_id, userId, usePoint, productCode, amount, isValid, payDay, totalPrice
        FROM payments
        WHERE receipt_id LIKE '%' || p_receiptId || '%';

    v_payment payment_cursor%ROWTYPE;
BEGIN
    -- ������ ��й�ȣ�� SHA-256���� �ؽ�
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- ������ ��ȿ�� Ȯ��
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ �α��ο� �����߽��ϴ�.');
    ELSE
        -- �˻��� ���� ��� ��� ����
        DBMS_OUTPUT.PUT_LINE('�˻��� ���� ���:');
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('������ ID | ����� ID | ���� ����Ʈ | ��ǰ �ڵ� | ���� | ��ȿ�� | ������ | �� ����');
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------');

        -- Ŀ�� ���� �� ���� ���� ��ȸ
        OPEN payment_cursor;
        LOOP
            FETCH payment_cursor INTO v_payment;
            EXIT WHEN payment_cursor%NOTFOUND;

            -- ���� ���� ���
            DBMS_OUTPUT.PUT_LINE(
                v_payment.receipt_id || ' | ' ||
                v_payment.userId || ' | ' ||
                v_payment.usePoint || ' | ' ||
                v_payment.productCode || ' | ' ||
                v_payment.amount || ' | ' ||
                v_payment.isValid || ' | ' ||
                v_payment.payDay || ' | ' ||
                v_payment.totalPrice
            );
        END LOOP;

        -- Ŀ�� �ݱ�
        CLOSE payment_cursor;
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('�ش� ������ ã�� �� �����ϴ�: ' || p_receiptId);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
        RAISE;
END;
/

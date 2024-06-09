-- 회원 가입 프로시저
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
    v_isValid NUMBER := 1; -- 기본값은 1로
    v_hashedPw RAW(32); -- 비밀번호 암호화 변수
    v_userPoint NUMBER := 50;
BEGIN
    -- 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_userPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- users 테이블에 입력받은 회원정보 입력
    INSERT INTO users (
        userId, userPw, isValid, userBirthday, userJoinDate, userAddress,
        userDetail_address, userEmail, userName, userPhone, userPoint
    ) VALUES (
        p_userId, RAWTOHEX(v_hashedPw), v_isValid, p_userBirthday, p_userJoinDate, p_userAddress,
        p_userDetail_address, p_userEmail, p_userName, p_userPhone, v_userPoint
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('회원가입이 완료되었습니다.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- 관리자 등록 프로시저
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
    -- 기존 관리자 비밀번호를 SHA-256으로 해시
    v_existingHashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_existingAdminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- 기존 관리자 유효성 확인
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_existingAdminId
    AND adminPassword = RAWTOHEX(v_existingHashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('관리자 로그인에 실패했습니다.');
    ELSE
        -- 새로운 관리자 비밀번호를 SHA-256으로 해시
        v_newHashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_newAdminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
        
        -- 새로운 관리자 정보 저장
        INSERT INTO admins (adminId, adminPassword, adminPosition)
        VALUES (p_newAdminId, RAWTOHEX(v_newHashedPw), p_newAdminPosition);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('새 관리자 등록이 완료되었습니다.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- 회원 정보 출력 프로시저
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
    -- 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_userPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- 사용자 유효성 확인
    SELECT COUNT(*)
    INTO v_userCount
    FROM users
    WHERE userId = p_userId
    AND userPw = RAWTOHEX(v_hashedPw);

    IF v_userCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('회원 로그인에 실패했습니다.');
    ELSE
        -- 사용자 정보 조회
        SELECT isValid, userBirthday, userJoinDate, userAddress, userDetail_address, userEmail, userName, userPhone, userPoint
        INTO v_isValid, v_userBirthday, v_userJoinDate, v_userAddress, v_userDetail_address, v_userEmail, v_userName, v_userPhone, v_userPoint
        FROM users
        WHERE userId = p_userId;

        -- isValid 값이 0인 경우 유효하지 않은 회원 메시지 출력
        IF v_isValid = 0 THEN
            DBMS_OUTPUT.PUT_LINE('유효하지 않은 회원입니다.');
        ELSE
            -- 사용자 정보 출력
            DBMS_OUTPUT.PUT_LINE('해당하는 회원 정보입니다.');
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
        DBMS_OUTPUT.PUT_LINE('사용자를 찾을 수 없습니다: ' || p_userId);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        RAISE;
END;
/

-- 회원 정보 수정 프로시저
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
    -- 현재 비밀번호를 SHA-256으로 해시
    v_hashedCurrentPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_currentPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    
    BEGIN
        -- 사용자 유효성 및 현재 비밀번호 확인
        SELECT COUNT(*), isValid
        INTO v_userCount, v_isValid
        FROM users
        WHERE userId = p_userId
        AND userPw = RAWTOHEX(v_hashedCurrentPw)
        GROUP BY isValid;

        IF v_userCount = 0 THEN
            DBMS_OUTPUT.PUT_LINE('회원 로그인에 실패했습니다.');
        ELSIF v_isValid = 0 THEN
            DBMS_OUTPUT.PUT_LINE('유효하지 않은 회원입니다.');
        ELSE
            -- 새 비밀번호를 SHA-256으로 해시
            v_hashedNewPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_newPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

            -- 사용자 정보 업데이트
            UPDATE users
            SET userPw = RAWTOHEX(v_hashedNewPw),
                userBirthday = p_userBirthday,
                userAddress = p_userAddress,
                userDetail_address = p_userDetail_address,
                userEmail = p_userEmail,
                userName = p_userName,
                userPhone = p_userPhone
            WHERE userId = p_userId;
            
            -- 결과 메시지 출력
            IF SQL%ROWCOUNT > 0 THEN
                COMMIT;
                DBMS_OUTPUT.PUT_LINE('사용자 정보가 성공적으로 업데이트되었습니다.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('사용자 정보 업데이트에 실패했습니다: ' || p_userId);
            END IF;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('회원 로그인에 실패했습니다.');
    END;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- 상품 등록 프로시저
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
    -- 관리자 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    
    -- 관리자 로그인 확인
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);
    
    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('관리자 로그인에 실패했습니다.');
    ELSE
        -- 상품 정보 등록
        INSERT INTO products (productName, productCategory, productImage, productPrice, productStock)
        VALUES (p_productName, p_productCategory, p_productImage, p_productPrice, p_productStock);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('상품이 성공적으로 등록되었습니다.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- 전체 상품 목록 출력 프로시저
CREATE OR REPLACE PROCEDURE show_all_products IS
    CURSOR product_cursor IS
        SELECT productCode, productName, productCategory, productImage, productPrice, productStock
        FROM products;
    
    v_product product_cursor%ROWTYPE;
BEGIN
    -- 상품 정보 출력 시작
    DBMS_OUTPUT.PUT_LINE('등록된 상품 목록:');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('코드 | 이름 | 카테고리 | 이미지 URL | 가격 | 재고');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------');

    -- 커서 열기 및 상품 정보 순회
    OPEN product_cursor;
    LOOP
        FETCH product_cursor INTO v_product;
        EXIT WHEN product_cursor%NOTFOUND;

        -- 상품 정보 출력
        DBMS_OUTPUT.PUT_LINE(
            v_product.productCode || ' | ' ||
            v_product.productName || ' | ' ||
            v_product.productCategory || ' | ' ||
            v_product.productImage || ' | ' ||
            v_product.productPrice || ' | ' ||
            v_product.productStock
        );
    END LOOP;

    -- 커서 닫기
    CLOSE product_cursor;
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        RAISE;
END;
/

-- 상품 검색 프로시저
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
    -- 상품 검색 결과 출력 시작
    DBMS_OUTPUT.PUT_LINE('검색 결과:');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('코드 | 이름 | 카테고리 | 이미지 URL | 가격 | 재고');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------');

    -- 커서 열기 및 상품 정보 순회
    OPEN product_cursor;
    LOOP
        FETCH product_cursor INTO v_product;
        EXIT WHEN product_cursor%NOTFOUND;

        -- 상품 정보 출력
        DBMS_OUTPUT.PUT_LINE(
            v_product.productCode || ' | ' ||
            v_product.productName || ' | ' ||
            v_product.productCategory || ' | ' ||
            v_product.productImage || ' | ' ||
            v_product.productPrice || ' | ' ||
            v_product.productStock
        );
    END LOOP;

    -- 커서 닫기
    CLOSE product_cursor;
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        RAISE;
END;
/

-- 관리자 삭제 프로시저
CREATE OR REPLACE PROCEDURE delete_admin (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;
BEGIN
    -- 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    
    -- 관리자 존재 여부 확인
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('잘못된 관리자 정보를 입력하였습니다.');
    ELSE
        -- 관리자 삭제
        DELETE FROM admins
        WHERE adminId = p_adminId
        AND adminPassword = RAWTOHEX(v_hashedPw);

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('관리자가 성공적으로 삭제되었습니다.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- 상품 삭제 프로시저
CREATE OR REPLACE PROCEDURE delete_product (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2,
    p_productCode IN NUMBER
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;
BEGIN
    -- 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    
    -- 관리자 로그인 확인
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);
    
    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('관리자 로그인에 실패했습니다.');
    ELSE
        -- 상품 삭제
        DELETE FROM products
        WHERE productCode = p_productCode;
        
        IF SQL%ROWCOUNT > 0 THEN
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('상품이 성공적으로 삭제되었습니다.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('해당 상품을 찾을 수 없습니다: ' || p_productCode);
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- 전체 회원 목록 출력 프로시저
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
    -- 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- 관리자 로그인 확인
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('관리자 로그인에 실패했습니다.');
    ELSE
        -- 회원 목록 출력 시작
        DBMS_OUTPUT.PUT_LINE('전체 회원 목록:');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('아이디 | 유효성 | 생년월일 | 가입일 | 주소 | 상세 주소 | 이메일 | 이름 | 전화번호 | 포인트');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------');

        -- 커서 열기 및 회원 정보 순회
        OPEN user_cursor;
        LOOP
            FETCH user_cursor INTO v_user;
            EXIT WHEN user_cursor%NOTFOUND;

            -- 회원 정보 출력
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

        -- 커서 닫기
        CLOSE user_cursor;
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        RAISE;
END;
/
-- 회원 탈퇴 프로시저
CREATE OR REPLACE PROCEDURE delete_user (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2,
    p_userId IN VARCHAR2
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;
    v_isValid NUMBER := 0;
BEGIN
    -- 관리자 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- 관리자 유효성 확인
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('관리자 로그인에 실패했습니다.');
    ELSE
        -- 회원 존재 및 상태 확인
        SELECT isValid
        INTO v_isValid
        FROM users
        WHERE userId = p_userId;

        IF SQL%NOTFOUND THEN
            DBMS_OUTPUT.PUT_LINE('존재하지 않는 회원입니다.');
        ELSIF v_isValid = 0 THEN
            DBMS_OUTPUT.PUT_LINE('이미 탈퇴처리된 회원입니다.');
        ELSE
            -- 회원 탈퇴 처리
            UPDATE users
            SET isValid = 0
            WHERE userId = p_userId;

            COMMIT;
            DBMS_OUTPUT.PUT_LINE('회원 탈퇴 처리가 완료되었습니다.');
        END IF;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('존재하지 않는 회원입니다.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- 회원 정보 수정 프로시저
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
    -- 관리자 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    
    -- 관리자 로그인 확인
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);
    
    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('관리자 로그인에 실패했습니다.');
    ELSE
        -- 상품 정보 수정
        UPDATE products
        SET productName = p_productName,
            productCategory = p_productCategory,
            productImage = p_productImage,
            productPrice = p_productPrice,
            productStock = p_productStock
        WHERE productCode = p_productCode;

        -- 결과 메시지 출력
        IF SQL%ROWCOUNT > 0 THEN
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('상품 정보가 성공적으로 수정되었습니다.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('해당 상품을 찾을 수 없습니다: ' || p_productCode);
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- 관리자 정보 수정 프로시저
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
    -- 관리자 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    
    -- 관리자 유효성 확인
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);
    
    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('관리자 로그인에 실패했습니다.');
    ELSE
        -- 수정할 관리자 비밀번호를 SHA-256으로 해시
        v_newHashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_newAdminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
        
        -- 관리자 정보 수정
        UPDATE admins
        SET adminPassword = RAWTOHEX(v_newHashedPw),
            adminPosition = p_newAdminPosition
        WHERE adminId = p_targetAdminId;
        
        -- 결과 메시지 출력
        IF SQL%ROWCOUNT > 0 THEN
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('관리자 정보가 성공적으로 수정되었습니다.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('해당 관리자를 찾을 수 없습니다: ' || p_targetAdminId);
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- 관리자 정보 출력 프로시저
CREATE OR REPLACE PROCEDURE show_admin_info (
    p_adminId IN VARCHAR2,
    p_adminPw IN VARCHAR2
) IS
    v_hashedPw RAW(32);
    v_adminCount NUMBER := 0;
    v_adminPosition VARCHAR2(255);
BEGIN
    -- 관리자 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    
    -- 관리자 유효성 확인
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);
    
    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('관리자 로그인에 실패했습니다.');
    ELSE
        -- 관리자 정보 조회
        SELECT adminPosition
        INTO v_adminPosition
        FROM admins
        WHERE adminId = p_adminId;
        
        -- 관리자 정보 출력
        DBMS_OUTPUT.PUT_LINE('관리자 정보:');
        DBMS_OUTPUT.PUT_LINE('관리자 ID: ' || p_adminId);
        DBMS_OUTPUT.PUT_LINE('직책: ' || v_adminPosition);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('관리자를 찾을 수 없습니다: ' || p_adminId);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        RAISE;
END;
/

-- 전체 관리자 목록 출력 프로시저
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
    -- 관리자 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- 관리자 유효성 확인
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('관리자 로그인에 실패했습니다.');
    ELSE
        -- 관리자 목록 출력 시작
        DBMS_OUTPUT.PUT_LINE('전체 관리자 목록:');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('관리자 ID | 직책');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');

        -- 커서 열기 및 관리자 정보 순회
        OPEN admin_cursor;
        LOOP
            FETCH admin_cursor INTO v_admin;
            EXIT WHEN admin_cursor%NOTFOUND;

            -- 관리자 정보 출력
            DBMS_OUTPUT.PUT_LINE(v_admin.adminId || ' | ' || v_admin.adminPosition);
        END LOOP;

        -- 커서 닫기
        CLOSE admin_cursor;
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        RAISE;
END;
/

-- 관리자 검색 프로시저
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
    -- 관리자 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- 관리자 유효성 확인
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('관리자 로그인에 실패했습니다.');
    ELSE
        -- 관리자 검색 결과 출력 시작
        DBMS_OUTPUT.PUT_LINE('검색된 관리자 목록:');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('관리자 ID | 직책');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');

        -- 커서 열기 및 관리자 정보 순회
        OPEN admin_cursor;
        LOOP
            FETCH admin_cursor INTO v_admin;
            EXIT WHEN admin_cursor%NOTFOUND;

            -- 관리자 정보 출력
            DBMS_OUTPUT.PUT_LINE(v_admin.adminId || ' | ' || v_admin.adminPosition);
        END LOOP;

        -- 커서 닫기
        CLOSE admin_cursor;
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        RAISE;
END;
/

-- 회원 검색 프로시저
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
    -- 관리자 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- 관리자 유효성 확인
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('관리자 로그인에 실패했습니다.');
    ELSE
        -- 회원 검색 결과 출력 시작
        DBMS_OUTPUT.PUT_LINE('검색된 회원 목록:');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('아이디 | 유효성 | 생년월일 | 가입일 | 주소 | 상세 주소 | 이메일 | 이름 | 전화번호 | 포인트');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------');

        -- 커서 열기 및 회원 정보 순회
        OPEN user_cursor;
        LOOP
            FETCH user_cursor INTO v_user;
            EXIT WHEN user_cursor%NOTFOUND;

            -- 회원 정보 출력
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

        -- 커서 닫기
        CLOSE user_cursor;
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        RAISE;
END;
/

-- 전체 결제 목록 출력 프로시저
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
    -- 관리자 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- 관리자 유효성 확인
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('관리자 로그인에 실패했습니다.');
    ELSE
        -- 결제 목록 출력 시작
        DBMS_OUTPUT.PUT_LINE('전체 결제 목록:');
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('영수증 ID | 사용자 ID | 사용된 포인트 | 상품 코드 | 수량 | 유효성 | 결제일 | 총 가격');
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------');

        -- 커서 열기 및 결제 정보 순회
        OPEN payment_cursor;
        LOOP
            FETCH payment_cursor INTO v_payment;
            EXIT WHEN payment_cursor%NOTFOUND;

            -- 결제 정보 출력
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

        -- 커서 닫기
        CLOSE payment_cursor;
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        RAISE;
END;
/

-- 결제 프로시저
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
    v_receiptId VARCHAR2(20); -- 영수증 ID의 크기를 늘림
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
    -- 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_userPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- 사용자 유효성 및 비밀번호 확인
    SELECT COUNT(*), isValid, userPoint
    INTO v_userCount, v_isValid, v_newPoints
    FROM users
    WHERE userId = p_userId
    AND userPw = RAWTOHEX(v_hashedPw)
    GROUP BY isValid, userPoint;

    IF v_userCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('회원 로그인에 실패했습니다.');
        RETURN;
    ELSIF v_isValid = 0 THEN
        DBMS_OUTPUT.PUT_LINE('유효하지 않은 회원입니다.');
        RETURN;
    END IF;

    -- 상품 정보 확인 및 재고 확인
    SELECT productPrice, productStock
    INTO v_productPrice, v_productStock
    FROM products
    WHERE productCode = p_productCode;

    IF v_productStock < p_amount THEN
        DBMS_OUTPUT.PUT_LINE('재고가 부족합니다.');
        RETURN;
    END IF;

    -- 재고 업데이트
    UPDATE products
    SET productStock = productStock - p_amount
    WHERE productCode = p_productCode;

    -- 총 결제금액 계산
    v_totalPrice := v_productPrice * p_amount;

    -- 포인트 적립 계산 (1% 적립)
    v_earnedPoints := ROUND(v_totalPrice * 0.01);

    -- 사용자 포인트 업데이트
    v_newPoints := v_newPoints - p_usePoint + v_earnedPoints;
    UPDATE users
    SET userPoint = v_newPoints
    WHERE userId = p_userId;

    -- 영수증 번호 생성
    v_receiptId := generate_receipt_id;

    -- 결제 정보 저장
    INSERT INTO payments (
        receipt_id, userId, usePoint, productCode, amount, isValid, payDay, totalPrice
    ) VALUES (
        v_receiptId, p_userId, p_usePoint, p_productCode, p_amount, 1, v_payDay, v_totalPrice
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('결제가 완료되었습니다. 영수증 번호: ' || v_receiptId);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('존재하지 않는 사용자 또는 상품입니다.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- 결제 취소 프로시저
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
    -- 관리자 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- 관리자 유효성 확인
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('관리자 로그인에 실패했습니다.');
        RETURN;
    END IF;

    -- 영수증의 유효성 확인 및 결제 정보 가져오기
    SELECT isValid, productCode, amount, usePoint, userId, totalPrice
    INTO v_isValid, v_productCode, v_amount, v_usePoint, v_userId, v_totalPrice
    FROM payments
    WHERE receipt_id = p_receiptId;

    IF v_isValid = 0 THEN
        DBMS_OUTPUT.PUT_LINE('이미 환불된 결제건입니다.');
        RETURN;
    END IF;

    -- 결제 유효성 취소
    UPDATE payments
    SET isValid = 0
    WHERE receipt_id = p_receiptId;

    -- 상품 재고 원위치
    UPDATE products
    SET productStock = productStock + v_amount
    WHERE productCode = v_productCode;

    -- 포인트 계산 (결제 금액의 1% 적립한 것을 반환)
    v_earnedPoints := ROUND(v_totalPrice * 0.01);

    -- 사용자 포인트 업데이트
    SELECT userPoint INTO v_userPoint FROM users WHERE userId = v_userId;
    v_userPoint := v_userPoint + v_usePoint - v_earnedPoints;
    UPDATE users
    SET userPoint = v_userPoint
    WHERE userId = v_userId;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('결제가 성공적으로 취소되었습니다. 영수증 번호: ' || p_receiptId);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('존재하지 않는 영수증 번호입니다: ' || p_receiptId);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- 결제 검색 프로시저
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
    -- 관리자 비밀번호를 SHA-256으로 해시
    v_hashedPw := DBMS_CRYPTO.Hash(UTL_I18N.STRING_TO_RAW(p_adminPw, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);

    -- 관리자 유효성 확인
    SELECT COUNT(*)
    INTO v_adminCount
    FROM admins
    WHERE adminId = p_adminId
    AND adminPassword = RAWTOHEX(v_hashedPw);

    IF v_adminCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('관리자 로그인에 실패했습니다.');
    ELSE
        -- 검색된 결제 목록 출력 시작
        DBMS_OUTPUT.PUT_LINE('검색된 결제 목록:');
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('영수증 ID | 사용자 ID | 사용된 포인트 | 상품 코드 | 수량 | 유효성 | 결제일 | 총 가격');
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------');

        -- 커서 열기 및 결제 정보 순회
        OPEN payment_cursor;
        LOOP
            FETCH payment_cursor INTO v_payment;
            EXIT WHEN payment_cursor%NOTFOUND;

            -- 결제 정보 출력
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

        -- 커서 닫기
        CLOSE payment_cursor;
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 결제를 찾을 수 없습니다: ' || p_receiptId);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        RAISE;
END;
/

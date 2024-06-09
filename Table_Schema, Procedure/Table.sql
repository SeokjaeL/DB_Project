-- 상품 테이블
CREATE TABLE products (
    productCode NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    productName VARCHAR2(255),
    productCategory VARCHAR2(255),
    productImage VARCHAR2(255),
    productPrice NUMBER,
    productStock NUMBER
);

-- 회원 테이블
CREATE TABLE users (
  userId VARCHAR2(255) PRIMARY KEY,
  userPw VARCHAR2(255),
  isValid NUMBER(1),
  userBirthday DATE,
  userJoinDate TIMESTAMP,
  userAddress VARCHAR2(255),
  userDetail_address VARCHAR2(255),
  userEmail VARCHAR2(255),
  userName VARCHAR2(255),
  userPhone VARCHAR2(20),
  userPoint NUMBER
);

-- 관리자 테이블
CREATE TABLE admins (
    adminId VARCHAR2(255) PRIMARY KEY,
    adminPassword VARCHAR2(255),
    adminPosition VARCHAR2(255)
);

-- 상품 리뷰 테이블
CREATE TABLE product_review (
    reviewId NUMBER PRIMARY KEY,
    memberId VARCHAR2(255),
    productCode NUMBER,
    creationDate DATE,
    ratingScore NUMBER,
    reviewContent VARCHAR2(4000),
    FOREIGN KEY (productCode) REFERENCES products(productCode),
    FOREIGN KEY (memberId) REFERENCES users(userId)
);

-- 결제 테이블
CREATE TABLE payments (
    receipt_id VARCHAR2(255) PRIMARY KEY,
    userId VARCHAR2(255),
    usePoint NUMBER,
    productCode NUMBER,
    amount NUMBER,
    isValid NUMBER(1), -- Changed to CHAR(1) to represent BOOLEAN
    payDay TIMESTAMP,
    totalPrice NUMBER,
    FOREIGN KEY (userId) REFERENCES users(userId),
    FOREIGN KEY (productCode) REFERENCES products(productCode)
);

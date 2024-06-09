SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    search_mode NUMBER;
    search_value VARCHAR2(255);
BEGIN
    -- 검색 모드 입력 받기(검색 모드(1: 이름, 2: 카테고리))
    search_mode := &search_mode;

    -- 검색 값 입력 받기
    search_value := '&search_value';
    
    -- 상품 검색 프로시저 호출
    search_products(
        p_search_mode => search_mode,
        p_search_value => search_value
    );
END;
/

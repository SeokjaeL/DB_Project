SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

DECLARE
    search_mode NUMBER;
    search_value VARCHAR2(255);
BEGIN
    -- �˻� ��� �Է� �ޱ�(�˻� ���(1: �̸�, 2: ī�װ�))
    search_mode := &search_mode;

    -- �˻� �� �Է� �ޱ�
    search_value := '&search_value';
    
    -- ��ǰ �˻� ���ν��� ȣ��
    search_products(
        p_search_mode => search_mode,
        p_search_value => search_value
    );
END;
/

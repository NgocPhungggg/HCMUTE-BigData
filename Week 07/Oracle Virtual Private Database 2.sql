------- open database
ALTER PLUGGABLE DATABASE ORCLPDB OPEN;
------1.Quy?n EXEMPT ACCESS POLICY------
CREATE OR REPLACE FUNCTION no_records (p_schema  IN  VARCHAR2 DEFAULT NULL, p_object  IN  VARCHAR2 DEFAULT NULL) 
RETURN VARCHAR2 
AS   
BEGIN   
RETURN '1=0'; 
END; 
----------------------------------------
BEGIN 
DBMS_RLS.add_policy 
    (object_schema     => 'SCOTT', 
    object_name        => 'EMP', 
    policy_name        => 'NOT_DELETE', 
    function_schema    => 'SEC_MGR', 
    policy_function    => 'No_Records', 
    statement_types    => 'DELETE'); 
END; 
-----------------sec_mgr----------------
CREATE USER backup_mgr IDENTIFIED BY backup;
GRANT dba TO backup_mgr IDENTIFIED BY backup; 
----------------backup_mgr--------------
DELETE FROM scott.emp;
-----------------sec_mgr----------------
GRANT EXEMPT ACCESS POLICY TO backup_mgr;
----------------backup_mgr--------------
DELETE FROM scott.emp; 
ROLLBACK;

--2.Giám sát quy?n EXEMPT ACCESS POLICY--
-----------------sec_mgr----------------
SELECT grantee FROM dba_sys_privs 
WHERE PRIVILEGE = 'EXEMPT ACCESS POLICY'; 
-----------------sec_mgr----------------
AUDIT EXEMPT ACCESS POLICY BY ACCESS
----------------backup_mgr--------------
DELETE FROM scott.emp; 
ROLLBACK; 
-----------------sec_mgr----------------
SET SERVEROUTPUT ON;
-----------------sec_mgr----------------
BEGIN 
FOR rec IN 
(SELECT * FROM dba_audit_trail 
WHERE username = 'BACKUP_MGR' 
ORDER BY timestamp) 
LOOP 
DBMS_OUTPUT.put_line ('-------------------------'); 
DBMS_OUTPUT.put_line ('Who: ' || rec.username); 
DBMS_OUTPUT.put_line ('What: ' || rec.action_name 
                               || ' on ' || rec.owner 
                               || '.'    || rec.obj_name); DBMS_OUTPUT.put_line ('When: '  
|| TO_CHAR(rec.timestamp,'MM/DD HH24:MI')); 
DBMS_OUTPUT.put_line ('Using: ' || rec.priv_used); 
    END LOOP; 
END; 

---3.X? lý l?i cho Policy Function---
-----------------sec_mgr----------------
CREATE TABLE test(id int);
INSERT INTO test VALUES(1); 
CREATE PUBLIC SYNONYM testTable FOR test; 
-----------------sec_mgr----------------
CREATE OR REPLACE FUNCTION pred_function (p_schema  IN  VARCHAR2 DEFAULT NULL, p_object  IN  VARCHAR2 DEFAULT NULL) 
RETURN VARCHAR2 
AS total  NUMBER; 
BEGIN
    SELECT COUNT (*) INTO total FROM testTable; 
    RETURN '1 <= ' || total; 
END; 
-----------------sec_mgr----------------
BEGIN   
DBMS_RLS.add_policy   
    (object_schema     => 'SCOTT',
    object_name        => 'DEPT',
    policy_name        => 'debug',
    function_schema    => 'SEC_MGR',
    policy_function    => 'pred_function'); 
END; 
-----------------scott----------------
SELECT COUNT(*) FROM dept; 
-----------------sec_mgr----------------
DROP TABLE test;
-----------------scott----------------
SELECT COUNT(*) FROM dept; 
-----------------sec_mgr----------------
FLASHBACK TABLE test TO BEFORE DROP;
-----------------scott----------------
SELECT COUNT(*) FROM dept;  
-----------------sec_mgr----------------
CREATE OR REPLACE FUNCTION pred_function (p_schema  IN  VARCHAR2 DEFAULT NULL, p_object  IN  VARCHAR2 DEFAULT NULL) 
RETURN VARCHAR2 
AS total NUMBER; 
BEGIN 
    EXECUTE IMMEDIATE 'SELECT COUNT (*) FROM testTable' 
    INTO total; 
    RETURN '1 <= ' || total; 
    EXCEPTION 
    WHEN OTHERS THEN RETURN '1 = 0'; 
END; 
-----------------scott----------------
SELECT COUNT(*) FROM dept; 


---------4. Column Sensitive VPD---------
-----------------sec_mgr----------------
CREATE OR REPLACE FUNCTION user_only (p_schema  IN  VARCHAR2 DEFAULT NULL, p_object  IN  VARCHAR2 DEFAULT NULL) 
RETURN VARCHAR2 
AS 
BEGIN   	 	    
    RETURN 'ename = user'; 
END; 
-----------------sec_mgr----------------
BEGIN   
    DBMS_RLS.add_policy   
        (object_schema       => 'SCOTT', 
        object_name          => 'EMP',
        policy_name          => 'people_sel_sal',
        function_schema      => 'SEC_MGR',
        policy_function      => 'user_only',
        statement_types      => 'SELECT',
        sec_relevant_cols    => 'SAL,HIREDATE'); 
END; 
-----------------scott----------------
SELECT ename,job 
FROM emp 
WHERE ename >= 'S'; 
-----------------scott----------------
SELECT ename,sal 
FROM emp; 
-----------------scott----------------
SELECT ename,hiredate 
FROM emp; 
-----------------scott----------------
SELECT ename,hiredate,sal 
FROM emp;
----------------backup_mgr--------------
SELECT ename 
FROM scott.emp 
WHERE ename >= 'S' AND sal > 1000; 
------------------scott----------------
SELECT ename 
FROM emp 
WHERE ename >= 'S' AND sal > 1000; 
-----------------sec_mgr----------------
BEGIN   
    -- Xóa chính sách hi?n t?i   
    DBMS_RLS.drop_policy
        (object_schema 	=> 'SCOTT', 
        object_name 	=> 'EMP', 
        policy_name  	=> 'people_sel_sal'); 
    -- T?o l?i chính sách v?i thay ??i ?  
    -- tham s? SEC_RELEVANT_COLS_OPT   
    DBMS_RLS.add_policy   
        (object_schema 	=> 'SCOTT',
        object_name 	=> 'EMP',
        policy_name  	=> 'people_sel_sal',
        function_schema  => 'SEC_MGR',
        policy_function => 'user_only',
        statement_types => 'SELECT',
        sec_relevant_cols => 'SAL,HIREDATE', 
        sec_relevant_cols_opt => DBMS_RLS.all_rows); 
END; 
------------------scott----------------
SELECT ename,job,sal,hiredate 
FROM emp 
WHERE ename >= 'S' ; 


----------------Bài t?p tu?n---------------
--------da lam o bai tap tuan truoc--------
CREATE TABLE SCOTT.EMPHOLIDAY 
    (EmpNo NUMBER(5),
    Name VARCHAR2(60),
    Holiday DATE);
INSERT INTO SCOTT.EMPHOLIDAY (EmpNo, Name, Holiday) VALUES (1, 'HAN', TO_DATE('02/01/2010', 'DD/MM/YYYY'));
INSERT INTO SCOTT.EMPHOLIDAY (EmpNo, Name, Holiday) VALUES (2, 'AN', TO_DATE('12/05/2010', 'DD/MM/YYYY'));
INSERT INTO SCOTT.EMPHOLIDAY (EmpNo, Name, Holiday) VALUES (3, 'THU', TO_DATE('26/08/2009', 'DD/MM/YYYY'));
COMMIT;

CREATE USER AN IDENTIFIED BY an;
CREATE USER THU IDENTIFIED BY thu;
CREATE USER HAN IDENTIFIED BY han;

GRANT CONNECT TO AN;
GRANT CONNECT TO THU;
GRANT CONNECT TO HAN;

GRANT SELECT, INSERT, UPDATE, DELETE ON scott.EMPHOLIDAY TO an;
GRANT SELECT, INSERT, UPDATE, DELETE ON scott.EMPHOLIDAY TO thu;
GRANT SELECT, INSERT, UPDATE, DELETE ON scott.EMPHOLIDAY TO han;
---------------------Cau 1---------------------
-----------------sec_mgr----------------
CREATE OR REPLACE FUNCTION holiday_control(
    p_schema  IN  VARCHAR2 DEFAULT NULL,
    p_object  IN  VARCHAR2 DEFAULT NULL) 
RETURN VARCHAR2 
AS 
BEGIN
    RETURN 'Name = USER';    -- Ch? cho phép xem thông tin c?a chính nhân viên
EXCEPTION -- Khi x?y ra l?i, tr? v? m?t ?i?u ki?n an toàn ?? b?o v? thông tin
    WHEN OTHERS THEN
        RETURN '1 = 0';
END;
-----------------sec_mgr----------------
BEGIN
    DBMS_RLS.add_policy(
        object_schema       => 'SCOTT',
        object_name         => 'EMPHOLIDAY',
        policy_name         => 'holiday_control_policy',
        function_schema     => 'SEC_MGR',
        policy_function     => 'holiday_control',
        statement_types     => 'SELECT');
END;

---------------------Cau 2---------------------
-----------------sec_mgr----------------
CREATE OR REPLACE FUNCTION holiday_control(
    p_schema  IN  VARCHAR2 DEFAULT NULL,
    p_object  IN  VARCHAR2 DEFAULT NULL) 
RETURN VARCHAR2 
AS 
BEGIN
    IF SYS_CONTEXT('USERENV', 'SESSION_USER') = 'AN' THEN
        RETURN 'Name = USER';  -- Ch? cho phép "An" xem thông tin c?a chính mình
    ELSE
        RETURN '1 = 0';  -- Không cho phép ng??i dùng khác xem b?t k? thông tin nào
    END IF;
EXCEPTION -- Khi x?y ra l?i, tr? v? m?t ?i?u ki?n an toàn ?? b?o v? thông tin
    WHEN OTHERS THEN
        RETURN '1 = 0';
END;
-----------------sec_mgr----------------
BEGIN
    -- Xóa chính sách c? n?u ?ã t?n t?i
    DBMS_RLS.drop_policy(
        object_schema   => 'SCOTT',
        object_name     => 'EMPHOLIDAY',
        policy_name     => 'holiday_control_policy');
    -- Thêm chính sách m?i
    DBMS_RLS.add_policy(
        object_schema       => 'SCOTT',
        object_name         => 'EMPHOLIDAY',
        policy_name         => 'holiday_control_policy',
        function_schema     => 'SEC_MGR',  -- ??m b?o schema ch?a function là ?úng
        policy_function     => 'holiday_control',
        statement_types     => 'SELECT',  -- Áp d?ng cho các câu l?nh SELECT
        sec_relevant_cols   => 'Holiday'); 
END;
-----------------AN----------------
SELECT EMPNO, Name, Holiday FROM scott.EMPHOLIDAY;
SELECT Holiday FROM scott.EMPHOLIDAY;
-----------------HAN----------------
SELECT EMPNO, Name, Holiday FROM scott.EMPHOLIDAY;

---------------------Cau 3---------------------
GRANT EXEMPT ACCESS POLICY TO HAN;
AUDIT EXEMPT ACCESS POLICY BY ACCESS;
AUDIT DELETE ON scott.EMPHOLIDAY BY ACCESS;

-----------------HAN----------------
SELECT * FROM scott.EMPHOLIDAY;
DELETE FROM scott.EMPHOLIDAY;
SELECT * FROM scott.EMPHOLIDAY;
ROLLBACK;
SELECT * FROM scott.EMPHOLIDAY;

SET SERVEROUTPUT ON;

-----------------sec_mgr----------------
SELECT * FROM DBA_AUDIT_TRAIL WHERE USERNAME = 'HAN' AND ACTION_NAME = 'DELETE';
-----CaoThiNgocPhung-21110276


---------------------Cau 4---------------------
-----------------sec_mgr----------------
CREATE TABLE EMPLOYEE (
    empno NUMBER PRIMARY KEY,
    ename VARCHAR2(100),
    email VARCHAR2(100),
    salary NUMBER,
    deptno NUMBER);

INSERT INTO EMPLOYEE (empno, ename, email, salary, deptno) VALUES (1, 'PHUNG', 'phung@gmail.com', 50000, 10);
INSERT INTO EMPLOYEE (empno, ename, email, salary, deptno) VALUES (2, 'TIEN', 'tien@gmail.com', 55000, 20);
INSERT INTO EMPLOYEE (empno, ename, email, salary, deptno) VALUES (3, 'BACH', 'bach@gmail.com', 60000, 10);
INSERT INTO EMPLOYEE (empno, ename, email, salary, deptno) VALUES (4, 'THUONG', 'thuong@gmail.com', 65000, 30);
INSERT INTO EMPLOYEE (empno, ename, email, salary, deptno) VALUES (5, 'KHANG', 'khang@gmail.com', 70000, 20);

CREATE USER PHUNG IDENTIFIED BY phung;
CREATE USER TIEN IDENTIFIED BY tien;
CREATE USER BACH IDENTIFIED BY bach;
CREATE USER THUONG IDENTIFIED BY thuong;
CREATE USER KHANG IDENTIFIED BY khang;
GRANT CONNECT TO PHUNG;
GRANT CONNECT TO TIEN;
GRANT CONNECT TO BACH;
GRANT CONNECT TO THUONG;
GRANT CONNECT TO KHANG;
GRANT SELECT, UPDATE ON EMPLOYEE TO PHUNG;
GRANT SELECT, UPDATE ON EMPLOYEE TO TIEN;
GRANT SELECT, UPDATE ON EMPLOYEE TO BACH;
GRANT SELECT, UPDATE ON EMPLOYEE TO THUONG;
GRANT SELECT, UPDATE ON EMPLOYEE TO KHANG;


-------------------xem cac nhan vien cung phong-------------------
CREATE OR REPLACE FUNCTION select_policy (
    p_schema IN VARCHAR2,
    p_object IN VARCHAR2
) RETURN VARCHAR2 
AS
    user_deptno sec_mgr.EMPLOYEE.deptno%TYPE;
BEGIN
    SELECT deptno INTO user_deptno
    FROM sec_mgr.EMPLOYEE
    WHERE ename = USER;
    RETURN 'deptno = ' || user_deptno;
EXCEPTION
    WHEN OTHERS THEN
        RETURN '1 = 0';
END;
BEGIN
    DBMS_RLS.DROP_POLICY(
        object_schema   => 'sec_mgr',
        object_name     => 'EMPLOYEE',
        policy_name     => 'select_employee_policy');
END;
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'sec_mgr',
        object_name     => 'EMPLOYEE',
        policy_name     => 'select_employee_policy',
        function_schema => 'sec_mgr',
        policy_function => 'select_policy',
        statement_types => 'SELECT',
        sec_relevant_cols => 'email, salary');
END;
----CaoThiNgocPhung21110276
SELECT *
FROM sec_mgr.EMPLOYEE;

-------------------chi update email c?a ban than-------------------
CREATE OR REPLACE FUNCTION update_policy (
        p_schema IN VARCHAR2 DEFAULT NULL, 
        p_object IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 
AS
BEGIN
    RETURN 'ename = USER';
EXCEPTION
    WHEN OTHERS THEN
        RETURN '1 = 0';
END;

BEGIN
    DBMS_RLS.DROP_POLICY(
        object_schema   => 'sec_mgr',
        object_name     => 'EMPLOYEE',
        policy_name     => 'update_employee_policy'
    );
END;
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'sec_mgr',
        object_name     => 'EMPLOYEE',
        policy_name     => 'update_employee_policy',
        function_schema => 'sec_mgr',
        policy_function => 'update_policy',
        statement_types => 'UPDATE',
        sec_relevant_cols => 'email');
END;
-------------------khong ???c update info update c?a ban than-------------------
DROP FUNCTION no_update_policy;
CREATE OR REPLACE FUNCTION no_update_policy (
        p_schema IN VARCHAR2 DEFAULT NULL, 
        p_object IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 
AS
BEGIN
    RETURN '1 = 0';
END;

BEGIN
    DBMS_RLS.DROP_POLICY(
        object_schema   => 'sec_mgr',
        object_name     => 'EMPLOYEE',
        policy_name     => 'no_update_employee_policy'
    );
END;
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'sec_mgr',
        object_name     => 'EMPLOYEE',
        policy_name     => 'no_update_employee_policy',
        function_schema => 'sec_mgr',
        policy_function => 'no_update_policy',
        statement_types => 'UPDATE',
        sec_relevant_cols => 'empno, ename, salary, deptno');
END;
-----------------PHUNG----------
UPDATE SEC_MGR.EMPLOYEE
SET EMAIL = 'new_email@gmail.com'
WHERE ENAME = USER;
-----------------
UPDATE SEC_MGR.EMPLOYEE
SET EMAIL = 'email@gmail.com'
WHERE ENAME = 'BACH';
-----------------BACH----------
UPDATE SEC_MGR.EMPLOYEE
SET salary = 61
WHERE ENAME = USER;


---------------------Cau 5---------------------
CREATE TABLE EMPLOYEE_NEXT (
    EMPNO NUMBER PRIMARY KEY,
    ENAME VARCHAR2(50),
    EMAIL VARCHAR2(100),
    SALARY NUMBER,
    DEPTNO NUMBER,
    MANAGER NUMBER
);

INSERT INTO EMPLOYEE_NEXT (EMPNO, ENAME, EMAIL, SALARY, DEPTNO, MANAGER) VALUES (1, 'PHUNG', 'phung@gmail.com', 50000, 10, NULL);
INSERT INTO EMPLOYEE_NEXT (EMPNO, ENAME, EMAIL, SALARY, DEPTNO, MANAGER) VALUES (2, 'TIEN', 'tien@gmail.com', 55000, 10, 1);
INSERT INTO EMPLOYEE_NEXT (EMPNO, ENAME, EMAIL, SALARY, DEPTNO, MANAGER) VALUES (3, 'BACH', 'bach@gmail.com', 60000, 20, 5);
INSERT INTO EMPLOYEE_NEXT (EMPNO, ENAME, EMAIL, SALARY, DEPTNO, MANAGER) VALUES (4, 'THUONG', 'thuong@gmail.com', 65000, 30, NULL);
INSERT INTO EMPLOYEE_NEXT (EMPNO, ENAME, EMAIL, SALARY, DEPTNO, MANAGER) VALUES (5, 'KHANG', 'khang@gmail.com', 70000, 20, NULL);

GRANT SELECT, INSERT, UPDATE, DELETE ON EMPLOYEE_NEXT TO PHUNG;
GRANT SELECT ON EMPLOYEE_NEXT TO TIEN;
GRANT SELECT ON EMPLOYEE_NEXT TO BACH;
GRANT SELECT ON EMPLOYEE_NEXT TO THUONG;
GRANT SELECT, INSERT, UPDATE, DELETE ON EMPLOYEE_NEXT TO KHANG;

--------------------tao policy cho quan ly --------------------
CREATE OR REPLACE FUNCTION sec_mgr.manager_policy (
    p_schema IN VARCHAR2,
    p_object IN VARCHAR2
) RETURN VARCHAR2 
AS
    user_deptno sec_mgr.EMPLOYEE_NEXT.deptno%TYPE;
    is_manager  NUMBER(1);
BEGIN
    SELECT deptno, 
           CASE 
               WHEN manager IS NULL THEN 1
               ELSE 0
           END
    INTO user_deptno, is_manager
    FROM sec_mgr.EMPLOYEE_NEXT 
    WHERE ename = USER;
    IF is_manager = 1 THEN
        RETURN 'deptno = ' || user_deptno;
    ELSE
        RETURN '1 = 0';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN '1 = 0';
END;
BEGIN
    DBMS_RLS.DROP_POLICY(
        object_schema   => 'sec_mgr',
        object_name     => 'EMPLOYEE_NEXT',
        policy_name     => 'manager_policy_function');
    DBMS_RLS.ADD_POLICY(
        object_schema       => 'sec_mgr',
        object_name         => 'EMPLOYEE_NEXT',
        policy_name         => 'manager_policy_function',
        function_schema     => 'sec_mgr',
        policy_function     => 'manager_policy',
        statement_types     => 'INSERT,UPDATE,DELETE', 
        update_check        => TRUE); 
END;
-------------------xem cac nhan vien cung phong-------------------
CREATE OR REPLACE FUNCTION sec_mgr.select_policy_next (
    p_schema IN VARCHAR2,
    p_object IN VARCHAR2
) RETURN VARCHAR2 
AS
    user_deptno sec_mgr.EMPLOYEE_NEXT.deptno%TYPE;
BEGIN
    SELECT deptno INTO user_deptno
    FROM sec_mgr.EMPLOYEE_NEXT
    WHERE ename = USER;
    RETURN 'deptno = ' || user_deptno;
EXCEPTION
    WHEN OTHERS THEN
        RETURN '1 = 0';
END;
BEGIN
    DBMS_RLS.DROP_POLICY(
        object_schema   => 'sec_mgr',
        object_name     => 'EMPLOYEE_NEXT',
        policy_name     => 'select_policy_function_next');
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'sec_mgr',
        object_name     => 'EMPLOYEE_NEXT',
        policy_name     => 'select_policy_function_next',
        function_schema => 'sec_mgr',
        policy_function => 'select_policy_next',
        statement_types => 'SELECT',
        sec_relevant_cols => 'empno, ename, email, deptno, manager');
END;

-------------------chi xem salary cua minh-------------------
CREATE OR REPLACE FUNCTION salary_policy (
        p_schema IN VARCHAR2 DEFAULT NULL, 
        p_object IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 
AS
BEGIN
    RETURN 'ename = USER';
EXCEPTION
    WHEN OTHERS THEN
        RETURN '1 = 0';
END;

BEGIN
    DBMS_RLS.DROP_POLICY(
        object_schema   => 'sec_mgr',
        object_name     => 'EMPLOYEE_NEXT',
        policy_name     => 'salary_policy_function'
    );
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'sec_mgr',
        object_name     => 'EMPLOYEE_NEXT',
        policy_name     => 'salary_policy_function',
        function_schema => 'sec_mgr',
        policy_function => 'salary_policy',
        statement_types => 'SELECT',
        sec_relevant_cols => 'salary');
END;
------------Cao Th? Ng?c Ph?ng 21110276------------

SELECT ename
FROM sec_mgr.EMPLOYEE_NEXT;


    

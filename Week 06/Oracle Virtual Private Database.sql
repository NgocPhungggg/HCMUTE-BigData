Rem Cao Th? Ng?c Ph?ng
Rem 21110276
rem week 06

------- M? database
ALTER PLUGGABLE DATABASE ORCLPDB OPEN;

-------SCOTT (connection v?i SYS_ORCLPDB)-----
SET TERMOUT OFF
SET ECHO OFF

GRANT CONNECT,RESOURCE,UNLIMITED TABLESPACE TO SCOTT IDENTIFIED BY TIGER;
GRANT CREATE USER TO scott WITH ADMIN OPTION;
GRANT ALTER USER TO scott WITH ADMIN OPTION;
GRANT DROP USER TO scott WITH ADMIN OPTION;
GRANT CONNECT TO scott WITH ADMIN OPTION;
GRANT RESOURCE TO scott WITH ADMIN OPTION;
ALTER USER SCOTT DEFAULT TABLESPACE USERS;
ALTER USER SCOTT TEMPORARY TABLESPACE TEMP;
GRANT DBA TO scott WITH ADMIN OPTION;



------- 1.3 t?o database
CONNECT SCOTT/TIGER
DROP TABLE DEPT;
CREATE TABLE DEPT
       (DEPTNO NUMBER(2) CONSTRAINT PK_DEPT PRIMARY KEY,
	DNAME VARCHAR2(14) ,
	LOC VARCHAR2(13) ) ;
DROP TABLE EMP;
CREATE TABLE EMP
       (EMPNO NUMBER(4) CONSTRAINT PK_EMP PRIMARY KEY,
	ENAME VARCHAR2(10),
	JOB VARCHAR2(9),
	MGR NUMBER(4),
	HIREDATE DATE,
	SAL NUMBER(7,2),
	COMM NUMBER(7,2),
	DEPTNO NUMBER(2) CONSTRAINT FK_DEPTNO REFERENCES DEPT);
INSERT INTO DEPT VALUES
	(10,'ACCOUNTING','NEW YORK');
INSERT INTO DEPT VALUES (20,'RESEARCH','DALLAS');
INSERT INTO DEPT VALUES
	(30,'SALES','CHICAGO');
INSERT INTO DEPT VALUES
	(40,'OPERATIONS','BOSTON');
INSERT INTO EMP VALUES
(7369,'SMITH','CLERK',7902,to_date('17-12-1980','dd-mm-yyyy'),800,NULL,20);
INSERT INTO EMP VALUES
(7499,'ALLEN','SALESMAN',7698,to_date('20-2-1981','dd-mm-yyyy'),1600,300,30);
INSERT INTO EMP VALUES
(7521,'WARD','SALESMAN',7698,to_date('22-2-1981','dd-mm-yyyy'),1250,500,30);
INSERT INTO EMP VALUES
(7566,'JONES','MANAGER',7839,to_date('2-4-1981','dd-mm-yyyy'),2975,NULL,20);
INSERT INTO EMP VALUES
(7654,'MARTIN','SALESMAN',7698,to_date('28-9-1981','dd-mm-yyyy'),1250,1400,30);
INSERT INTO EMP VALUES
(7698,'BLAKE','MANAGER',7839,to_date('1-5-1981','dd-mm-yyyy'),2850,NULL,30);
INSERT INTO EMP VALUES
(7782,'CLARK','MANAGER',7839,to_date('9-6-1981','dd-mm-yyyy'),2450,NULL,10);
INSERT INTO EMP VALUES
(7788,'SCOTT','ANALYST',7566,to_date('13-JUL-87')-85,3000,NULL,20);
INSERT INTO EMP VALUES
(7839,'KING','PRESIDENT',NULL,to_date('17-11-1981','dd-mm-yyyy'),5000,NULL,10);
INSERT INTO EMP VALUES
(7844,'TURNER','SALESMAN',7698,to_date('8-9-1981','dd-mm-yyyy'),1500,0,30);
INSERT INTO EMP VALUES
(7876,'ADAMS','CLERK',7788,to_date('13-JUL-87')-51,1100,NULL,20);
INSERT INTO EMP VALUES
(7900,'JAMES','CLERK',7698,to_date('3-12-1981','dd-mm-yyyy'),950,NULL,30);
INSERT INTO EMP VALUES
(7902,'FORD','ANALYST',7566,to_date('3-12-1981','dd-mm-yyyy'),3000,NULL,20);
INSERT INTO EMP VALUES
(7934,'MILLER','CLERK',7782,to_date('23-1-1982','dd-mm-yyyy'),1300,NULL,10);
DROP TABLE BONUS;
CREATE TABLE BONUS
	(
	ENAME VARCHAR2(10)	,
	JOB VARCHAR2(9)  ,
	SAL NUMBER,
	COMM NUMBER
	) ;
DROP TABLE SALGRADE;
CREATE TABLE SALGRADE
      ( GRADE NUMBER,
	LOSAL NUMBER,
	HISAL NUMBER );
INSERT INTO SALGRADE VALUES (1,700,1200);
INSERT INTO SALGRADE VALUES (2,1201,1400);
INSERT INTO SALGRADE VALUES (3,1401,2000);
INSERT INTO SALGRADE VALUES (4,2001,3000);
INSERT INTO SALGRADE VALUES (5,3001,9999);
COMMIT;

SET TERMOUT ON
SET ECHO ON

---------Connection v?i scott b?ng user scott
GRANT CONNECT TO sec_mgr;
GRANT RESOURCE TO sec_mgr;
GRANT CREATE USER TO sec_mgr;
GRANT ALTER USER TO sec_mgr;
GRANT DROP USER TO sec_mgr;
GRANT CREATE SESSION TO SEC_MGR;
GRANT SELECT ON scott.emp TO sec_mgr;
GRANT INSERT, UPDATE ON SCOTT.EMP TO SEC_MGR;
GRANT EXECUTE ON DBMS_RLS TO sec_mgr;

--------- 1.2 T?o chính sách b?o m?t
SELECT * FROM scott.emp;
------------------
CREATE OR REPLACE FUNCTION no_dept10 (p_schema IN VARCHAR2, p_object IN VARCHAR2) 
RETURN VARCHAR2 
AS 
BEGIN 
    RETURN 'deptno != 10'; 
END;

--------- 1.3 ??ng ký function cho ??i t??ng mà chính sách ?ó mu?n b?o v?
BEGIN
    DBMS_RLS.add_policy(
        object_schema     => 'SCOTT', 
        object_name       => 'EMP', 
        policy_name       => 'quickstart', 
        policy_function   => 'no_dept10'
    );
END;
---------
SELECT DISTINCT deptno FROM scott.emp; 
---------
CREATE OR REPLACE FUNCTION no_dept10 ( 
    p_schema  IN  VARCHAR2, p_object  IN  VARCHAR2) 
RETURN VARCHAR2 
AS 
BEGIN 
    RETURN 'USER != ''SCOTT'''; 
END; 
---------
SELECT * FROM scott.emp; 
---------
SELECT COUNT(*) Total_Records FROM scott.emp; 
---------

--------- 3. Ki?m tra n?i dung chu?i tr? v? ---------
col predicate format a50; 
---------
SELECT no_dept10('SCOTT','EMP') predicate FROM DUAL; 
---------
CREATE OR REPLACE FUNCTION no_dept10 (p_schema  IN  VARCHAR2 DEFAULT NULL, p_object  IN  VARCHAR2 DEFAULT NULL) 
RETURN VARCHAR2 
AS 
BEGIN 
RETURN 'USER != ''SCOTT'''; 
END; 
---------
col predicate format a50; 
---------
SELECT no_dept10 predicate FROM DUAL; 
---------

--------- 4. Tham s? STATEMENT_TYPES---------
CREATE OR REPLACE FUNCTION dept_less_30 (p_schema  IN  VARCHAR2 DEFAULT NULL, p_object  IN  VARCHAR2 DEFAULT NULL) 
RETURN VARCHAR2 
AS  
BEGIN 
RETURN 'deptno < 30'; 
END; 
---------
BEGIN 
    DBMS_RLS.add_policy(
        object_schema     => 'SCOTT', 
        object_name       => 'EMP',
        policy_name       => 'EMP_IU', 
        function_schema   => 'SEC_MGR', 
        policy_function   => 'dept_less_30', 
        statement_types   => 'INSERT,UPDATE',
        update_check      => True
    ); 
END;
------
SELECT ename, deptno FROM scott.emp WHERE ename < 'F'; 
------
UPDATE emp SET deptno = 10 WHERE ename = 'ALLEN';
------


------5. K? thu?t ng?n truy xu?t t?t c? các hàng ------
CREATE OR REPLACE FUNCTION no_records (p_schema  IN  VARCHAR2 DEFAULT NULL, p_object  IN  VARCHAR2 DEFAULT NULL) 
RETURN VARCHAR2 
AS   
BEGIN   
RETURN '1=0'; 
END;
------
BEGIN 
DBMS_RLS.add_policy (
    object_schema     => 'SCOTT', 
    object_name        => 'EMP', 
    policy_name        => 'PEOPLE_RO_IUD', 
    function_schema    => 'SEC_MGR', 
    policy_function    => 'No_Records', 
    statement_types    => 'INSERT,UPDATE,DELETE', 
    update_check       => TRUE); 
END; 
-----
SELECT COUNT (*) FROM emp;
------
UPDATE emp  SET ename = NULL; 
------
DELETE FROM emp;
------
INSERT INTO emp (empno,ename) VALUES (25,'KNOX'); 

------6. Xóa chính sách b?o m?t ------
BEGIN 
    DBMS_RLS.drop_policy (
        object_schema     => 'SCOTT', 
        object_name        => 'EMP', 
        policy_name        => 'PEOPLE_RO_IUD'
    ); 
END; 

------------------------------------------BÀI T?P-----------------------------------
------- T?o b?ng EMPHOLIDAY------- Cao Th? Ng?c Ph?ng 21110276
CREATE TABLE scott.EMPHOLIDAY (
    EmpNo NUMBER(5),
    Name VARCHAR2(60),
    Holiday DATE
);
------- Chèn d? li?u vào b?ng EMPHOLIDAY
INSERT INTO scott.EMPHOLIDAY (EmpNo, Name, Holiday) VALUES (1, 'Han', TO_DATE('02/01/2010', 'DD/MM/YYYY'));
INSERT INTO scott.EMPHOLIDAY (EmpNo, Name, Holiday) VALUES (2, 'An', TO_DATE('12/05/2010', 'DD/MM/YYYY'));
INSERT INTO scott.EMPHOLIDAY (EmpNo, Name, Holiday) VALUES (3, 'Thu', TO_DATE('26/08/2009', 'DD/MM/YYYY'));
COMMIT;

------- T?o user ------- Cao Th? Ng?c Phung 21110276
CREATE USER AN IDENTIFIED BY an;
CREATE USER THU IDENTIFIED BY thu;
CREATE USER HAN IDENTIFIED BY han;

GRANT CONNECT TO AN;
GRANT CONNECT TO THU;
GRANT CONNECT TO HAN;

GRANT SELECT, INSERT, UPDATE, DELETE ON scott.EMPHOLIDAY TO an;
GRANT SELECT, INSERT, UPDATE, DELETE ON scott.EMPHOLIDAY TO thu;
GRANT SELECT, INSERT, UPDATE, DELETE ON scott.EMPHOLIDAY TO han;

-------
CREATE OR REPLACE FUNCTION sec_mgr.HolidayControlFunc (p_schema IN VARCHAR2 DEFAULT NULL,
                                                        p_object  IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 
AS
BEGIN
    IF SYS_CONTEXT('USERENV', 'SESSION_USER') = 'AN' THEN 
        RETURN 'Name = ''An'''; -- An ch? có th? xem và ch?nh s?a thông tin cá nhân c?a mình  
    ELSIF SYS_CONTEXT('USERENV', 'SESSION_USER') = 'THU' THEN
        RETURN '1 = 0'; -- Thu không ???c xem hay ch?nh s?a b?t k? thông tin nào
    ELSIF SYS_CONTEXT('USERENV', 'SESSION_USER') = 'HAN' THEN
        RETURN '1 = 1 AND (Holiday >= TRUNC(SYSDATE))';  
        -- Han có th? xem t?t c? thông tin và ch? ch?nh s?a nh?ng ngày l?n h?n ho?c b?ng ngày hi?n t?i
    ELSE
        RETURN '1 = 0';  -- Tr??ng h?p không phù h?p v?i b?t k? ?i?u ki?n nào, t? ch?i truy c?p
    END IF;
    RETURN NULL; -- Tr??ng h?p không phù h?p v?i b?t k? ?i?u ki?n nào
END;
-------Cao Th? Ng?c Ph?ng 21110267
BEGIN
    DBMS_RLS.ADD_POLICY (
        object_schema   => 'SCOTT',                         -- Schema ch?a b?ng c?n ???c b?o v?
        object_name     => 'EMPHOLIDAY',                    -- Tên b?ng
        policy_name     => 'HolidayControlPolicy',          -- Tên policy
        function_schema => 'SEC_MGR',                       -- Schema ch?a hàm policy
        policy_function => 'HolidayControlFunc',            -- Tên hàm policy
        statement_types => 'SELECT, INSERT, UPDATE, DELETE',-- Các lo?i câu l?nh áp d?ng
        update_check    => TRUE                             -- Ki?m tra ?i?u ki?n trong các thao tác UPDATE
    );
END;
------- ??ng nh?p v?i user an và ki?m tra
SELECT * FROM scott.EMPHOLIDAY;
-------
UPDATE scott.EMPHOLIDAY
SET Holiday = TO_DATE('15/10/2024', 'DD/MM/YYYY') 
WHERE Name = 'Thu';
-------
UPDATE scott.EMPHOLIDAY ----
SET Holiday = TO_DATE('15/10/2024', 'DD/MM/YYYY') 
WHERE Name = 'An';
-------
SELECT * FROM scott.EMPHOLIDAY;
-------

------- ??ng nh?p v?i user thu và ki?m tra
SELECT * FROM scott.EMPHOLIDAY;
-------Cao Thi Ngoc Phung 21110267
UPDATE scott.EMPHOLIDAY
SET Holiday = TO_DATE('15/10/2024', 'DD/MM/YYYY') 
WHERE Name = 'Thu';
-------

------- ng nh?p v?i user Han và ki?m tra
SELECT * FROM scott.EMPHOLIDAY;
-----Cao Thi Ngoc Phung 21110267
UPDATE scott.EMPHOLIDAY
SET Holiday = TO_DATE('26/8/2008', 'DD/MM/YYYY') 
WHERE Name = 'Thu';
-------Cao Thi Ngoc Phung 21110267
UPDATE scott.EMPHOLIDAY 
SET Holiday = TO_DATE('15/11/2024', 'DD/MM/YYYY') 
WHERE Name = 'Thu';



ALTER PLUGGABLE DATABASE ORCLPDB OPEN;
---------------------------------------------
-----------------I.Gi?i thi?u----------------
---------------------------------------------

--------3.Kich hoat tai khoan LBACSYS--------
-------------------SYS_ORCL------------------
ALTER USER lbacsys IDENTIFIED BY lbacsys ACCOUNT UNLOCK ; 
---------------------------------------------

--------------4.Chuan bi du lieu-------------
-------------------SYS_ORCL------------------
ALTER USER hr IDENTIFIED BY hr ACCOUNT UNLOCK; 
-------------------SYS_ORCL------------------
GRANT connect, create user, drop user, create role, drop any role 
TO hr_sec IDENTIFIED BY hrsec; 
-------------------SYS_ORCL------------------
GRANT connect TO sec_admin IDENTIFIED BY secadmin; 
-------------------SYS_ORCL------------------
CREATE ROLE emp_role; 
GRANT connect TO emp_role; 
-------------------SYS_ORCL------------------
CREATE USER sking IDENTIFIED BY sking; 
GRANT emp_role TO sking; 
-------------------SYS_ORCL------------------
CREATE USER nkochhar IDENTIFIED BY nkochhar; 
GRANT emp_role TO nkochhar; 
-------------------SYS_ORCL------------------
CREATE USER kpartner IDENTIFIED BY kpartner; 
GRANT emp_role TO kpartner; 
-------------------SYS_ORCL------------------
CREATE USER ldoran IDENTIFIED BY ldoran; 
GRANT emp_role TO ldoran; 
---------------------HR----------------------
GRANT select ON hr.locations TO emp_role; 

---------------------------------------------
-----II.Chinh sach Oracle Label Security-----
---------------------------------------------

----------------1. T?o level-----------------
-----------------SYS_ORCLPDB-----------------
EXEC LBACSYS.CONFIGURE_OLS;
EXEC LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;
-----------------SYS_ORCLPDB-----------------
GRANT SYSDBA TO LBACSYS
-------------------LBACSYS-------------------
BEGIN 
    SA_SYSDBA.CREATE_POLICY ( 
        policy_name => 'ACCESS_LOCATIONS', 
        column_name => 'OLS_COLUMN'); 
END; 
-------------------LBACSYS-------------------
GRANT access_locations_dba TO sec_admin; 
-------------------LBACSYS-------------------
GRANT execute ON sa_components TO sec_admin; 
-------------------LBACSYS-------------------
GRANT execute ON sa_label_admin TO sec_admin; 
-------------------LBACSYS-------------------
GRANT execute ON sa_policy_admin TO sec_admin; 
-------------------LBACSYS-------------------
GRANT access_locations_dba TO hr_sec; 
-------------------LBACSYS-------------------
GRANT execute ON sa_user_admin TO hr_sec; 
-------------------LBACSYS-------------------
BEGIN sa_sysdba.create_policy (
    policy_name => 'Different_Policy'); 
END; 
------------------SEC_ADMIN------------------
BEGIN sa_components.create_level (
    policy_name => 'Different_Policy',
    long_name 	=> 'foo', 
    short_name 	=> 'bar', 
    level_num 	=> 9); 
END; 
-------------------LBACSYS-------------------
BEGIN sa_sysdba.drop_policy (
    policy_name => 'Different_Policy', 
    drop_column => true); 
END; 
------------------SEC_ADMIN------------------
BEGIN sa_components.create_level (
    policy_name => 'ACCESS_LOCATIONS', 
    long_name   => 'PUBLIC', 
    short_name  => 'PUB', 
    level_num   => 1000); 
END; 
------------------SEC_ADMIN------------------
BEGIN
   sa_components.create_level(
      'ACCESS_LOCATIONS',
      2000,
      'CONF',
      'CONFIDENTIAL'
   );
END;
------------------SEC_ADMIN------------------
BEGIN 
    sa_components.create_level (
        'ACCESS_LOCATIONS',
        3000,
        'SENS',
        'SENSITIVE');
END;
------------------SEC_ADMIN------------------
BEGIN 
    sa_components.create_level (
        'ACCESS_LOCATIONS',
        4000,
        'HS',
        'HIGHLY SECRET'); 
END;
------------------SEC_ADMIN------------------
BEGIN 
    sa_components.alter_level (
    policy_name     => 'ACCESS_LOCATIONS', 
    level_num       => 4000, 
    new_short_name  => 'TS', 
    new_long_name   => 'TOP SECRET'); 
END; 
------------------SEC_ADMIN------------------
BEGIN 
    sa_components.alter_level (
        policy_name 	=> 'ACCESS_LOCATIONS', 
        short_name  	=> 'TS', 
        new_long_name 	=> 'TOP SENSITIVE'); 
END; 
------------------SEC_ADMIN------------------
BEGIN 
    sa_components.drop_level (
        policy_name   => 'ACCESS_LOCATIONS', 
        short_name  => 'TS'); 
END; 

-------------2. T?o compartment--------------
------------------SEC_ADMIN------------------
----------------Xoa trung lap----------------
BEGIN
    sa_components.drop_compartment(
        policy_name => 'ACCESS_LOCATIONS', 
        short_name  => 'SM');
END;
------------------SEC_ADMIN------------------
BEGIN 
    LBACSYS.sa_components.create_compartment (
        policy_name   => 'ACCESS_LOCATIONS', 
        long_name      => 'SALES_MARKETING', 
        short_name     => 'SM', 
        comp_num       => 2000); 
END; 

BEGIN 
    sa_components.create_compartment (
        'ACCESS_LOCATIONS',
        3000,
        'FIN',
        'FINANCE'); 
END;
------------------SEC_ADMIN------------------
BEGIN 
    sa_components.create_compartment (
        'ACCESS_LOCATIONS',
        1000,
        'HR',
        'HUMAN RESOURCES'); 
END;
------------------SEC_ADMIN------------------
BEGIN 
    sa_components.create_compartment (
        'ACCESS_LOCATIONS', 
        4000, 
        'PR', 
        'PUBLIC RELATIONS'); 
END;
------------------SEC_ADMIN------------------
BEGIN 
    sa_components.alter_compartment (
        policy_name     => 'ACCESS_LOCATIONS', 
        comp_num        => 4000, 
        new_short_name  => 'PU', 
        new_long_name   => 'PURCHASING'); 
END; 
------------------SEC_ADMIN------------------
BEGIN 
    sa_components.alter_compartment (
        policy_name 	=> 'ACCESS_LOCATIONS', 
        short_name  	=> 'PU', 
        new_long_name 	=> 'PURCHASE'); 
END; 
------------------SEC_ADMIN------------------
BEGIN 
    sa_components.drop_compartment (
        policy_name => 'ACCESS_LOCATIONS', 
        short_name  => 'PU'); 
END; 

-------------------3.group-------------------
------------------SEC_ADMIN------------------
BEGIN
    sa_components.create_group (
        policy_name => 'ACCESS_LOCATIONS',
        long_name   => 'CORPORATE',
        short_name  => 'CORP', 
        group_num   => 10, 
        parent_name => NULL); 
END; 
------------------SEC_ADMIN------------------
BEGIN
    sa_components.create_group(
        'ACCESS_LOCATIONS', 
        30, 
        'US', 
        'UNITED STATES', 
        'CORP');
END; 
------------------SEC_ADMIN------------------
BEGIN      
    sa_components.create_group(
        'ACCESS_LOCATIONS', 
        50, 
        'UK', 
        'UNITED KINGDOM', 
        'CORP');
END; 
------------------SEC_ADMIN------------------
BEGIN        
    sa_components.create_group(
        'ACCESS_LOCATIONS', 
        70, 
        'CA', 
        'CANADA', 
        'CORP');
END;
------------------SEC_ADMIN------------------
BEGIN 
    sa_components.create_group (
        'ACCESS_LOCATIONS',
        90,
        'FR',
        'FRANCE',
        'CORP');
END;
------------------SEC_ADMIN------------------
BEGIN 
    sa_components.alter_group (
        policy_name     => 'ACCESS_LOCATIONS', 
        group_num       => 90, 
        new_short_name  => 'RFR', 
        new_long_name   => 'REPUBLIC FRANCE'); 
END; 
------------------SEC_ADMIN------------------
BEGIN 
    sa_components.alter_group (
        policy_name 	=> 'ACCESS_LOCATIONS', 
        short_name  	=> 'RFR', 
        new_long_name 	=> 'PURCHASE'); 
END; 
------------------SEC_ADMIN------------------
BEGIN 
    sa_components.drop_group (
        policy_name => 'ACCESS_LOCATIONS', 
        short_name  => 'RFR'); 
END; 
------------------SEC_ADMIN------------------

---------------------------------------------
---------IV.Chi ti?t v? nhãn d? li?u---------
---------------------------------------------

------------------SEC_ADMIN------------------
BEGIN 	 	 
    sa_label_admin.create_label (
        policy_name => 'ACCESS_LOCATIONS', 
        label_tag 	=> 10000, 
        label_value => 'PUB'); 
END; 
------------------SEC_ADMIN------------------
BEGIN 
    sa_label_admin.create_label (
        'ACCESS_LOCATIONS',
        20000,
        'CONF');
END; 
------------------SEC_ADMIN------------------
BEGIN 
    sa_label_admin.create_label (
        'ACCESS_LOCATIONS',
        20010,
        'CONF::US');
END;
------------------SEC_ADMIN------------------
BEGIN 
    sa_label_admin.create_label (
        'ACCESS_LOCATIONS',
        20020,
        'CONF::UK'); 
END;
------------------SEC_ADMIN------------------
BEGIN
    sa_label_admin.create_label(
        'ACCESS_LOCATIONS',
        20030,
        'CONF::CA');
END;
------------------SEC_ADMIN------------------
BEGIN 	 
    sa_label_admin.drop_label (
        policy_name  	=> 'ACCESS_LOCATIONS', 
        label_tag 	 	=> 21020);
END;
------------------SEC_ADMIN------------------
BEGIN
    sa_label_admin.create_label(
        'ACCESS_LOCATIONS',
        21020,
        'CONF:HR:UK'
    );
END;
------------------SEC_ADMIN------------------
BEGIN
    sa_label_admin.create_label(
        'ACCESS_LOCATIONS',
        22040,
        'CONF:SM:UK,CA'
    );
END;
------------------SEC_ADMIN------------------
BEGIN
    sa_label_admin.create_label(
        'ACCESS_LOCATIONS',
        34000,
        'SENS:SM,FIN'
    );
END;
------------------SEC_ADMIN------------------
BEGIN
    sa_label_admin.create_label(
        'ACCESS_LOCATIONS',
        39090,
        'SENS:HR,SM,FIN:CORP'
    );
END;
------------------SEC_ADMIN------------------
BEGIN 
    sa_label_admin.create_label (
        'ACCESS_LOCATIONS',
        30000,
        'SENS');
END;
------------------SEC_ADMIN------------------
BEGIN
    sa_label_admin.create_label (
        'ACCESS_LOCATIONS',
        30091,
        'SENS::CORP');
END;
------------------SEC_ADMIN------------------
BEGIN
    sa_label_admin.alter_label (
        policy_name  	=> 'ACCESS_LOCATIONS',
        label_tag 	 	=> 30000, 
        new_label_value 	=> 'SENS:SM'); 
    sa_label_admin.alter_label (
        policy_name  	=> 'ACCESS_LOCATIONS', 
        label_value  	=> 'SENS:SM', 
        new_label_value 	=> 'SENS:HR'); 
END; 
------------------SEC_ADMIN------------------
BEGIN
    sa_label_admin.drop_label(
        policy_name   => 'ACCESS_LOCATIONS',
        label_value   => 'SENS:HR');
END;
------------------SEC_ADMIN------------------
BEGIN
    sa_label_admin.drop_label(
        policy_name   => 'ACCESS_LOCATIONS',
        label_tag     => 30090);
END;


---------------------------------------------
------------------V.Bai tap------------------
---------------------------------------------

----Bai 1. Tao user ols_test va cap quyen de user nay truy cap vao he thong duoc. 
----Cap quyen thuc thi tren cac goi thu tuc can thiet de user nay quan ly duoc mot chinh sach."
-----------------SYS_ORCLPDB-----------------
GRANT connect TO ols_test IDENTIFIED BY olstest; 

----2. Tao chinh sach region_policy voi ten cot chinh sach la region_label. 
----Thuc hien lenh can thiet de ols_test tro thanh nguoi quan ly chinh sach nay.
-------------------LBACSYS-------------------
BEGIN
    SA_SYSDBA.CREATE_POLICY(
        policy_name => 'region_policy',  
        column_name => 'region_label');
END;
-------------------LBACSYS-------------------
GRANT region_policy_dba TO ols_test; 
GRANT EXECUTE ON sa_policy_admin TO ols_test;
GRANT EXECUTE ON sa_label_admin TO ols_test;
GRANT EXECUTE ON sa_components TO ols_test;


----3. Disable thu tuc da tao o cau 2. Sau do enable no lai
-------------------SYS-------------------
GRANT INHERIT PRIVILEGES ON USER LBACSYS TO LBACSYS;
GRANT INHERIT PRIVILEGES ON USER LBACSYS TO OLS_TEST;

-----------------SYS_ORCLPDB-----------------
BEGIN
    SA_SYSDBA.DISABLE_POLICY(
        policy_name => 'region_policy');
END;
-----------------SYS_ORCLPDB-----------------
BEGIN
    SA_SYSDBA.ENABLE_POLICY(
        policy_name => 'region_policy');
END;

------1. Tao cac thanh phan nhan cho chinh sach region_policy
-------------------LEVEL------------------
-----------------OLS_TEST-----------------
BEGIN
    sa_components.create_level (
        policy_name => 'region_policy',
        long_name   => 'Level 1', 
        short_name  => 'L1', 
        level_num   => 1);
END;
BEGIN
    sa_components.create_level (
        policy_name => 'region_policy',
        long_name   => 'Level 2', 
        short_name  => 'L2', 
        level_num   => 2);
END;

BEGIN
    sa_components.create_level (
        policy_name => 'region_policy',
        long_name   => 'Level 3', 
        short_name  => 'L3', 
        level_num   => 3);
END;
-----------------COMPARTMENT----------------
BEGIN 
    sa_components.create_compartment (
        policy_name   => 'region_policy', 
        long_name      => 'MANAGEMENT', 
        short_name     => 'MN', 
        comp_num       => 1000); 
END; 
BEGIN 
    sa_components.create_compartment (
        policy_name   => 'region_policy', 
        long_name      => 'EMPLOYEE', 
        short_name     => 'EMP', 
        comp_num       => 2000); 
END; 


-----------------GROUP----------------
----------GROUP--REGION NORTH---------
BEGIN
    sa_components.create_group (
        policy_name   => 'region_policy',
        long_name     => 'REGION NORTH',
        short_name    => 'RN',
        group_num     => 101);
END;

----------GROUP--REGION SOUTH---------
BEGIN
    sa_components.create_group (
        policy_name   => 'region_policy',
        long_name     => 'REGION SOUTH',
        short_name    => 'RS',
        group_num     => 102);
END;

----------GROUP--REGION EAST---------
BEGIN
    sa_components.create_group (
        policy_name   => 'region_policy',
        long_name     => 'REGION EAST',
        short_name    => 'RE',
        group_num     => 103);
END;

----------GROUP--REGION WEST---------
BEGIN
    sa_components.create_group (
        policy_name   => 'region_policy',
        long_name     => 'REGION WEST',
        short_name    => 'RW',
        group_num     => 104);
END;
------Cao Thi Ngoc Phung 21110276-----






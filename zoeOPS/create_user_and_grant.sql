-- Created in 2018.06.03 by polarbears
-- Copyright (c) 20xx, CHINA and/or affiliates.
-- All rights reserved.
--	Name:
-- 		create_user_and_grant.sql
--	Description:
-- 		创建运维相关用户（ZOEDBA,ZOEDEVOPS,ZOECHECKUP）并授权
--  Relation:
--      zoeUtility
--	Notes:
--		首先安装zoeUtility工具包
--	修改 - （年-月-日） - 描述
--


SET SERVEROUTPUT ON 
--定义运维管理存储表空间
DEFINE sv_tablespace_name = ZOEOPS_TAB
--运维管理DBA用户
DEFINE sv_dbauser = ZOEDBA
--运维管理基本用户
DEFINE sv_opsusername = ZOEDEVOPS
--运维管理健康检查用户
DEFINE sv_checkupusername = ZOECHECKUP
-- ===================================================
-- 创建表空间: ZOEOPS_TAB 
--
   --不支持裸设备，仅支持文件系统                                             
-- ===================================================
DECLARE
  lv_name             VARCHAR2(512);
  lv_dir              VARCHAR2(512);
  lv_sql              VARCHAR2(4000);
  lv_sysfile_name     VARCHAR2(513);
  lv_tablespace_name  VARCHAR2(64);
BEGIN
  lv_tablespace_name := '&sv_tablespace_name';
  SELECT file_name INTO lv_sysfile_name FROM dba_data_files where tablespace_name = 'SYSTEM' AND ROWNUM=1;
  IF SUBSTR(lv_sysfile_name,1,1) = '+' or SUBSTR(lv_sysfile_name,1,1) = '/' THEN
    SELECT file_name      
    INTO lv_name
    FROM dba_data_files
    WHERE tablespace_name='SYSTEM' and rownum = 1;
    lv_dir              := SUBSTR(lv_name,1,instr(lv_name,'/',-1));
    lv_sql              := 'CREATE TABLESPACE '||lv_tablespace_name||' ';
    lv_sql              := lv_sql||'LOGGING ' ;
    lv_sql              := lv_sql||'DATAFILE '''||lv_dir||lv_tablespace_name||'01.ora'' SIZE 10M REUSE ';
    lv_sql              := lv_sql||'AUTOEXTEND ON NEXT 10M MAXSIZE 16000M ';
    lv_sql              := lv_sql||'EXTENT MANAGEMENT LOCAL';
    EXECUTE immediate lv_sql;
    --dbms_output.put_line(lv_sql);
  ELSE
    SELECT file_name      
    INTO lv_name
    FROM dba_data_files
    WHERE tablespace_name='SYSTEM' and rownum = 1;
    lv_dir              := SUBSTR(lv_name,1,instr(lv_name,'\',-1));
    lv_sql              := 'CREATE TABLESPACE '||lv_tablespace_name||' ';
    lv_sql              := lv_sql||'LOGGING ' ;
    lv_sql              := lv_sql||'DATAFILE '''||lv_dir||lv_tablespace_name||'01.ora'' SIZE 10M REUSE ';
    lv_sql              := lv_sql||'AUTOEXTEND ON NEXT 10M MAXSIZE 16000M ';
    lv_sql              := lv_sql||'EXTENT MANAGEMENT LOCAL';
    EXECUTE immediate lv_sql;
    --dbms_output.put_line(lv_sql);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  dbms_output.put_line(SQLCODE||'--'||sqlerrm);
END;
/

-- ===================================================
-- 创建DBA用户                                        
-- ===================================================
VAR sv_password         VARCHAR2(128)
DECLARE
lv_password VARCHAR2(128);
lv_sql_ddl  VARCHAR2(400);
BEGIN
SELECT  DBMS_RANDOM.STRING('X',12) INTO :sv_password FROM DUAL;
lv_password := 'zoe'||:sv_password;
lv_sql_ddl := 'CREATE USER &sv_dbauser IDENTIFIED BY '||lv_password||' DEFAULT TABLESPACE &sv_tablespace_name';
DBMS_OUTPUT.PUT_LINE(lv_password);
EXECUTE IMMEDIATE lv_sql_ddl;
END;
/

-- ===================================================
-- 创建数据库健康检查用户                                        
-- ===================================================
VAR sv_password         VARCHAR2(128)
DECLARE
lv_password VARCHAR2(128);
lv_sql_ddl  VARCHAR2(400);
BEGIN
SELECT  DBMS_RANDOM.STRING('X',12) INTO :sv_password FROM DUAL;
lv_password := 'zoe'||:sv_password;
lv_sql_ddl := 'CREATE USER &sv_checkupusername IDENTIFIED BY '||lv_password||' DEFAULT TABLESPACE &sv_tablespace_name';
DBMS_OUTPUT.PUT_LINE(lv_password);
EXECUTE IMMEDIATE lv_sql_ddl;
END;
/

-- ===================================================
-- 创建敏捷运维用户                                        
-- ===================================================
VAR sv_password         VARCHAR2(128)
DECLARE
lv_password VARCHAR2(128);
lv_sql_ddl  VARCHAR2(400);
BEGIN
SELECT  DBMS_RANDOM.STRING('X',12) INTO :sv_password FROM DUAL;
lv_password := 'zoe'||:sv_password;
lv_sql_ddl := 'CREATE USER &sv_opsusername IDENTIFIED BY '||lv_password||' DEFAULT TABLESPACE &sv_tablespace_name';
DBMS_OUTPUT.PUT_LINE(lv_password);
EXECUTE IMMEDIATE lv_sql_ddl;
END;
/


-- ===================================================
-- 授权系统权限给运维用户
--
   --                                           
-- ===================================================
GRANT DBA TO ZOEDBA;

ALTER USER ZOEDEVOPS QUOTA UNLIMITED ON ZOEOPS_TAB;
ALTER USER ZOECHECKUP QUOTA UNLIMITED ON ZOEOPS_TAB;
GRANT EXECUTE ON  SYS.DBMS_CRYPTO                 TO ZOEDEVOPS;
GRANT EXECUTE ON  SYS.UTL_I18N                    TO ZOEDEVOPS;
GRANT EXECUTE ON  SYS.UTL_RAW                     TO ZOEDEVOPS;
GRANT EXECUTE ON  SYS.DBMS_OBFUSCATION_TOOLKIT    TO ZOEDEVOPS;
GRANT SELECT  ON  DBA_CONSTRAINTS                 TO ZOEDEVOPS;
GRANT SELECT  ON  DBA_CONS_COLUMNS                TO ZOEDEVOPS;
GRANT SELECT  ON  DBA_TAB_COLUMNS                 TO ZOEDEVOPS;



